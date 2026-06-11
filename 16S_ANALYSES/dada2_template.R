###############################################################################
# DADA2 pipeline — single batch, NovaSeq, HPC cluster (UNIL Curnagl)
#
# PURPOSE
#   Run DADA2 from raw fastq files through to taxonomy assignment for one
#   sequencing batch. Produces three output tables:
#     - abundance_table.txt     (ASVs x samples, read counts)
#     - taxonomy_table.txt      (ASVs x ranks, Kingdom through Species)
#     - correspondence_table.txt (ASV label <-> full DNA sequence)
#
# BEFORE RUNNING
#   1. Set the USER CONFIGURATION section below (paths, amplicon, read lengths)
#   2. Place your fastq.gz files in:   BASE/data/RUN_ID/
#   3. Place SILVA databases in:       BASE/db/
#      silva_nr99_v138.2_toGenus_trainset.fa.gz
#      silva_species_assignment_v138.2.fa.gz
#      Download from: https://benjjneb.github.io/dada2/training.html
#   4. Submit with: sbatch submit_dada2_run.sh
#
# CHECKPOINTS
#   Expensive steps are saved to disk as .rds files. If the job fails or
#   times out and you resubmit, completed steps are skipped automatically.
#   To force a step to rerun, delete the corresponding .rds file:
#     filterAndTrim  → delete dada2_filtered/ folder
#     learnErrors    → delete errF_RUN_ID.rds and errR_RUN_ID.rds
#     dada/merge     → delete seqtab_RUN_ID.rds
#     chimera        → delete seqtab_nochim_RUN_ID.rds
#     taxonomy       → delete taxa_RUN_ID.rds
#
# MULTI-BATCH DATASETS
#   If you have multiple sequencing runs, run this script once per batch
#   (changing RUN_ID each time), then use a separate merge script to combine
#   the per-batch seqtab_RUN_ID.rds files before chimera removal and taxonomy.
#   IMPORTANT: all batches must have the same amplicon region amplified.
#
# SEQUENCER NOTE
#   This script uses the NovaSeq-specific error model (makeBinnedQualErrfun).
#   NovaSeq 2-colour chemistry produces only 3 quality score bins (Q11, Q25, Q37).
#   The default DADA2 LOESS error fit oscillates badly on such data.
#   For MiSeq or HiSeq data, replace the learnErrors calls with:
#     errF <- learnErrors(filtFs, multithread = N_CORES)
#     errR <- learnErrors(filtRs, multithread = N_CORES)
###############################################################################


# ══════════════════════════════════════════════════════════════════════════════
# USER CONFIGURATION — edit this section before running
# ══════════════════════════════════════════════════════════════════════════════

# Unique identifier for this sequencing batch (used for file and folder names)
RUN_ID <- "run1"

# Root directory of your project on the cluster scratch space
BASE <- "/scratch/YOUR_USERNAME/YOUR_PROJECT"

# Fastq file naming pattern
# Novogene standard: SAMPLENAME_1.fastq.gz / SAMPLENAME_2.fastq.gz
# Illumina standard: SAMPLENAME_L001_R1_001.fastq.gz / _R2_001.fastq.gz
PATTERN_F <- "_1.fastq.gz"
PATTERN_R <- "_2.fastq.gz"

# Sample name extraction: strip everything from this string onward
# Must match the PATTERN above (e.g. "_1" for Novogene, "_L001_R1_001" for Illumina)
SPLIT_F <- "_1"
SPLIT_R <- "_2"

# Amplicon length filter — retain only merged sequences in this bp range
# Check the length histogram output and adjust to your amplicon:
#   V4  (~253 bp): seq(250, 256)
#   V3-V4 (~420 bp): seq(400, 432)
#   V3  (~193 bp): seq(190, 200)
ASV_LENGTH_MIN <- 250
ASV_LENGTH_MAX <- 256

# truncLen: length to truncate reads to before error learning and merging
# Set based on quality plots (where does the orange Q25 line start to dip?)
# OVERLAP CHECK: truncLenF + truncLenR - amplicon_length must be > 20 bp
#   Example: 220 + 200 - 253 = 167 bp overlap — good
# If Novogene pre-trimmed your reads (variable length < 250 bp), set both to 0
#   (omits truncation entirely — use this only if reads are already shorter
#    than the values above)
TRUNC_LEN_F <- 220
TRUNC_LEN_R <- 200

# Minimum overlap for paired-end merging (bp)
# Use 20 for standard amplicons (>40 bp expected overlap)
# Use 10 if reads are short and overlap is tight (e.g. V3-V4 with pre-trimmed reads)
MIN_OVERLAP <- 20

# Minimum reads per sample after filtering — samples below this are excluded
# from error learning and downstream steps
MIN_READS_FILTER <- 1000

# ══════════════════════════════════════════════════════════════════════════════
# END USER CONFIGURATION
# ══════════════════════════════════════════════════════════════════════════════


suppressPackageStartupMessages({
  library(dada2)
})

N_CORES <- as.integer(Sys.getenv("SLURM_CPUS_PER_TASK", unset = "1"))
cat(sprintf("[%s] DADA2 pipeline starting — %s — %d cores\n",
            format(Sys.time(), "%H:%M:%S"), RUN_ID, N_CORES))

# ── Derived paths (do not edit) ────────────────────────────────────────────
path    <- file.path(BASE, "data",    RUN_ID)
outdir  <- file.path(BASE, "results", RUN_ID)
filtdir <- file.path(path, "dada2_filtered")
dbdir   <- file.path(BASE, "db")

dir.create(outdir,                   showWarnings = FALSE, recursive = TRUE)
dir.create(filtdir,                  showWarnings = FALSE, recursive = TRUE)
dir.create(file.path(outdir, "Tables"), showWarnings = FALSE)

db_genus   <- file.path(dbdir, "silva_nr99_v138.2_toGenus_trainset.fa.gz")
db_species <- file.path(dbdir, "silva_v138.2_assignSpecies.fa.gz")

# ── Load and pair fastq files ──────────────────────────────────────────────
fnFs <- sort(list.files(path, pattern = PATTERN_F, full.names = TRUE))
fnRs <- sort(list.files(path, pattern = PATTERN_R, full.names = TRUE))

if (length(fnFs) == 0) stop("No forward fastq files found in: ", path)
if (length(fnRs) == 0) stop("No reverse fastq files found in: ", path)

sample.namesF <- sapply(strsplit(basename(fnFs), SPLIT_F), `[`, 1)
sample.namesR <- sapply(strsplit(basename(fnRs), SPLIT_R), `[`, 1)

cat(sprintf("[%s] Found %d F and %d R files\n",
            format(Sys.time(), "%H:%M:%S"), length(fnFs), length(fnRs)))

# Check for unpaired files
missing_R <- sample.namesR[!sample.namesR %in% sample.namesF]
missing_F <- sample.namesF[!sample.namesF %in% sample.namesR]
if (length(missing_R) > 0) cat("WARNING — in R2 but not R1:", paste(missing_R, collapse=", "), "\n")
if (length(missing_F) > 0) cat("WARNING — in R1 but not R2:", paste(missing_F, collapse=", "), "\n")

# ── Checkpoint: filterAndTrim ──────────────────────────────────────────────
filtFs <- file.path(filtdir, paste0(sample.namesF, "_F_filt.fastq.gz"))
filtRs <- file.path(filtdir, paste0(sample.namesR, "_R_filt.fastq.gz"))
names(filtFs) <- sample.namesF
names(filtRs) <- sample.namesR

already_filtered <- all(file.exists(filtFs)) &&
                    all(file.size(filtFs[file.exists(filtFs)]) > 0)

if (already_filtered) {
  cat(sprintf("[%s] Filtered files found — skipping filterAndTrim.\n",
              format(Sys.time(), "%H:%M:%S")))
  out <- as.matrix(read.table(
    file.path(outdir, paste0("read_retention_filter_", RUN_ID, ".txt")),
    sep = "\t", header = TRUE, row.names = 1))
} else {
  cat(sprintf("[%s] Starting filterAndTrim...\n", format(Sys.time(), "%H:%M:%S")))

  # truncLen: if TRUNC_LEN_F or TRUNC_LEN_R is 0, omit truncation entirely
  if (TRUNC_LEN_F > 0 && TRUNC_LEN_R > 0) {
    out <- filterAndTrim(fnFs, filtFs, fnRs, filtRs,
                         truncLen    = c(TRUNC_LEN_F, TRUNC_LEN_R),
                         maxN        = 0,
                         maxEE       = c(2, 2),
                         truncQ      = c(2, 2),
                         rm.phix     = TRUE,
                         matchIDs    = TRUE,
                         compress    = TRUE,
                         multithread = N_CORES)
  } else {
    # No truncation — use when reads are variable-length (e.g. Novogene pre-trimmed)
    cat(sprintf("[%s] TRUNC_LEN set to 0 — running without truncLen\n",
                format(Sys.time(), "%H:%M:%S")))
    out <- filterAndTrim(fnFs, filtFs, fnRs, filtRs,
                         maxN        = 0,
                         maxEE       = c(2, 2),
                         truncQ      = c(2, 2),
                         rm.phix     = TRUE,
                         matchIDs    = TRUE,
                         compress    = TRUE,
                         multithread = N_CORES)
  }

  retained <- as.data.frame(out)
  retained$percentage_retained <- retained$reads.out / retained$reads.in * 100
  write.table(retained,
              file.path(outdir, paste0("read_retention_filter_", RUN_ID, ".txt")),
              sep = "\t", quote = FALSE, row.names = TRUE, col.names = TRUE)
  cat(sprintf("[%s] filterAndTrim done. Median retention: %.1f%%\n",
              format(Sys.time(), "%H:%M:%S"),
              median(retained$percentage_retained, na.rm = TRUE)))
}

# Drop samples below the minimum read threshold
retained_df   <- as.data.frame(out)
samples_pass  <- retained_df$reads.out >= MIN_READS_FILTER
filtFs        <- filtFs[samples_pass]
filtRs        <- filtRs[samples_pass]
sample.namesF <- sample.namesF[samples_pass]
sample.namesR <- sample.namesR[samples_pass]
cat(sprintf("[%s] Samples retained after filter (%d+ reads): %d / %d\n",
            format(Sys.time(), "%H:%M:%S"), MIN_READS_FILTER,
            sum(samples_pass), length(samples_pass)))

# ── NovaSeq error model function ───────────────────────────────────────────
# Linear interpolation between Q11/Q25/Q37 bins instead of LOESS.
# Only used for NovaSeq data. See script header for MiSeq/HiSeq alternative.
makeBinnedQualErrfun <- function(binnedQ) {
  if (is.null(binnedQ)) stop("Quality bins must be provided.")
  function(trans, binnedQuals = binnedQ) {
    qq   <- as.numeric(colnames(trans))
    qmax <- max(qq[colSums(trans) > 0])
    qmin <- min(qq[colSums(trans) > 0])
    if (qmax > max(binnedQuals)) stop("Input Q higher than provided bins.")
    if (qmin < min(binnedQuals)) stop("Input Q lower than provided bins.")
    if (!qmax %in% binnedQuals) warning("Max observed Q not in provided bins.")
    if (!qmin %in% binnedQuals) warning("Min observed Q not in provided bins.")
    est <- matrix(0, nrow = 0, ncol = length(qq))
    for (nti in c("A","C","G","T")) {
      for (ntj in c("A","C","G","T")) {
        if (nti != ntj) {
          errs <- trans[paste0(nti,"2",ntj), ]
          tot  <- colSums(trans[paste0(nti,"2",c("A","C","G","T")), ])
          p    <- errs / tot
          df   <- data.frame(q=qq, errs=errs, tot=tot, p=p)
          if (!all(df$q == seq(nrow(df))-1)) stop("Unexpected Q score series.")
          pred <- rep(NA, nrow(df))
          for (i in seq(length(binnedQuals)-1)) {
            loQ <- binnedQuals[i]; hiQ <- binnedQuals[i+1]
            loP <- df$p[loQ+1];   hiP <- df$p[hiQ+1]
            if (!is.na(loP) && !is.na(hiP))
              pred[(loQ+1):(hiQ+1)] <- seq(loP, hiP, length.out=(hiQ-loQ+1))
          }
          maxrli <- max(which(!is.na(pred))); minrli <- min(which(!is.na(pred)))
          pred[seq_along(pred) > maxrli] <- pred[[maxrli]]
          pred[seq_along(pred) < minrli] <- pred[[minrli]]
          est <- rbind(est, pred)
        }
      }
    }
    MAX_ERROR_RATE <- 0.25; MIN_ERROR_RATE <- 1e-7
    est[est > MAX_ERROR_RATE] <- MAX_ERROR_RATE
    est[est < MIN_ERROR_RATE] <- MIN_ERROR_RATE
    err <- rbind(1-colSums(est[1:3,]),  est[1:3,],
                 est[4,], 1-colSums(est[4:6,]), est[5:6,],
                 est[7:8,], 1-colSums(est[7:9,]), est[9,],
                 est[10:12,], 1-colSums(est[10:12,]))
    rownames(err) <- paste0(rep(c("A","C","G","T"), each=4), "2", c("A","C","G","T"))
    colnames(err) <- colnames(trans)
    return(err)
  }
}

# ── Checkpoint: error models ───────────────────────────────────────────────
errF_path <- file.path(outdir, paste0("errF_", RUN_ID, ".rds"))
errR_path <- file.path(outdir, paste0("errR_", RUN_ID, ".rds"))

if (file.exists(errF_path) && file.exists(errR_path)) {
  cat(sprintf("[%s] Error models found — loading from disk.\n",
              format(Sys.time(), "%H:%M:%S")))
  errF <- readRDS(errF_path)
  errR <- readRDS(errR_path)
} else {
  binnedQs         <- c(11, 25, 37)   # NovaSeq quality bins
  binnedQualErrfun <- makeBinnedQualErrfun(binnedQs)
  cat(sprintf("[%s] Learning error rates (F)...\n", format(Sys.time(), "%H:%M:%S")))
  errF <- learnErrors(filtFs, errorEstimationFunction = binnedQualErrfun,
                      multithread = N_CORES)
  binnedQualErrfun <- makeBinnedQualErrfun(binnedQs)   # re-initialise for R
  cat(sprintf("[%s] Learning error rates (R)...\n", format(Sys.time(), "%H:%M:%S")))
  errR <- learnErrors(filtRs, errorEstimationFunction = binnedQualErrfun,
                      multithread = N_CORES)
  saveRDS(errF, errF_path)
  saveRDS(errR, errR_path)
  cat(sprintf("[%s] Error models saved.\n", format(Sys.time(), "%H:%M:%S")))
}

# ── Checkpoint: seqtab (derep + dada + merge + length filter) ─────────────
seqtab_path <- file.path(outdir, paste0("seqtab_", RUN_ID, ".rds"))

if (file.exists(seqtab_path)) {
  cat(sprintf("[%s] seqtab found — loading from disk.\n",
              format(Sys.time(), "%H:%M:%S")))
  seqtab <- readRDS(seqtab_path)
  getN <- function(x) sum(getUniques(x))
} else {

  getN <- function(x) sum(getUniques(x))

  # Dereplication: collapse identical reads to unique sequences
  cat(sprintf("[%s] Dereplicating...\n", format(Sys.time(), "%H:%M:%S")))
  derepFs <- derepFastq(filtFs, verbose = FALSE)
  derepRs <- derepFastq(filtRs, verbose = FALSE)
  names(derepFs) <- sample.namesF
  names(derepRs) <- sample.namesR

  # DADA2 sample inference
  cat(sprintf("[%s] Running dada() forward...\n", format(Sys.time(), "%H:%M:%S")))
  dadaFs <- dada(derepFs, err = errF, multithread = N_CORES)
  cat(sprintf("[%s] Running dada() reverse...\n", format(Sys.time(), "%H:%M:%S")))
  dadaRs <- dada(derepRs, err = errR, multithread = N_CORES)

  # Drop any samples with <100 denoised reads (secondary check)
  dada_reads  <- sapply(dadaRs, getN)
  samples_ok  <- dada_reads > 100
  if (any(!samples_ok)) {
    cat("WARNING — samples dropped after dada() (<100 denoised reads in R):\n")
    cat(paste(sample.namesR[!samples_ok], collapse = ", "), "\n")
  }
  dadaFs        <- dadaFs[samples_ok]
  dadaRs        <- dadaRs[samples_ok]
  derepFs       <- derepFs[samples_ok]
  derepRs       <- derepRs[samples_ok]
  sample.namesF <- sample.namesF[samples_ok]

  # Merge paired reads
  # Overlap = truncLenF + truncLenR - amplicon_length (must be > MIN_OVERLAP)
  cat(sprintf("[%s] Merging pairs (minOverlap=%d)...\n",
              format(Sys.time(), "%H:%M:%S"), MIN_OVERLAP))
  mergers <- mergePairs(dadaFs, derepFs, dadaRs, derepRs,
                        minOverlap  = MIN_OVERLAP,
                        maxMismatch = 0,
                        verbose     = FALSE)

  # Sequence table + length filter
  seqtab_raw <- makeSequenceTable(mergers)
  cat(sprintf("[%s] Length distribution before filter:\n",
              format(Sys.time(), "%H:%M:%S")))
  print(table(nchar(getSequences(seqtab_raw))))

  seqtab <- seqtab_raw[, nchar(colnames(seqtab_raw)) %in%
                          seq(ASV_LENGTH_MIN, ASV_LENGTH_MAX)]
  cat(sprintf("[%s] ASVs after length filter (%d-%d bp): %d\n",
              format(Sys.time(), "%H:%M:%S"),
              ASV_LENGTH_MIN, ASV_LENGTH_MAX, ncol(seqtab)))

  # Read tracking table (only available while dada objects are in memory)
  track <- cbind(
    out[retained_df$reads.out >= MIN_READS_FILTER, ][samples_ok, ],
    sapply(dadaFs, getN),
    sapply(dadaRs, getN),
    sapply(mergers, getN),
    rowSums(seqtab)
  )
  colnames(track) <- c("input", "filtered", "denoisedF", "denoisedR",
                        "merged", "seqtab")
  rownames(track) <- sample.namesF
  write.table(track,
              file.path(outdir, paste0("read_retention_full_", RUN_ID, ".txt")),
              sep = "\t", quote = FALSE, row.names = TRUE, col.names = TRUE)

  saveRDS(seqtab, seqtab_path)
  cat(sprintf("[%s] seqtab saved: %d samples x %d ASVs\n",
              format(Sys.time(), "%H:%M:%S"), nrow(seqtab), ncol(seqtab)))
}

# ── Checkpoint: chimera removal ────────────────────────────────────────────
nochim_path <- file.path(outdir, paste0("seqtab_nochim_", RUN_ID, ".rds"))

if (file.exists(nochim_path)) {
  cat(sprintf("[%s] seqtab_nochim found — loading from disk.\n",
              format(Sys.time(), "%H:%M:%S")))
  seqtab.nochim <- readRDS(nochim_path)
} else {
  cat(sprintf("[%s] Removing chimeras...\n", format(Sys.time(), "%H:%M:%S")))
  seqtab.nochim <- removeBimeraDenovo(seqtab,
                                      method      = "consensus",
                                      multithread = N_CORES,
                                      verbose     = TRUE)
  pct_reads <- (1 - sum(seqtab.nochim) / sum(seqtab)) * 100
  cat(sprintf("[%s] Chimeras removed: %d ASVs (%.1f%% of reads lost)\n",
              format(Sys.time(), "%H:%M:%S"),
              ncol(seqtab) - ncol(seqtab.nochim), pct_reads))
  saveRDS(seqtab.nochim, nochim_path)
}
cat(sprintf("[%s] Post-chimera: %d samples x %d ASVs\n",
            format(Sys.time(), "%H:%M:%S"),
            nrow(seqtab.nochim), ncol(seqtab.nochim)))

# ── Checkpoint: taxonomy ───────────────────────────────────────────────────
if (!file.exists(db_genus))   stop("Genus DB not found: ", db_genus)
if (!file.exists(db_species)) stop("Species DB not found: ", db_species)

taxa_path <- file.path(outdir, paste0("taxa_", RUN_ID, ".rds"))

if (file.exists(taxa_path)) {
  cat(sprintf("[%s] Taxa object found — loading from disk.\n",
              format(Sys.time(), "%H:%M:%S")))
  taxa <- readRDS(taxa_path)
} else {
  cat(sprintf("[%s] Assigning taxonomy (genus level)...\n",
              format(Sys.time(), "%H:%M:%S")))
  taxa <- assignTaxonomy(seqtab.nochim, db_genus,
                         multithread = N_CORES, tryRC = TRUE)
  cat(sprintf("[%s] Adding species by exact match...\n",
              format(Sys.time(), "%H:%M:%S")))
  taxa <- addSpecies(taxa, db_species)
  saveRDS(taxa, taxa_path)
}

NAs <- which(is.na(taxa[, 1]))
taxa[NAs, 1] <- "Unassigned"
cat(sprintf("[%s] Unassigned at Kingdom level: %d\n",
            format(Sys.time(), "%H:%M:%S"), length(NAs)))

cat(sprintf("[%s] Assignment rates:\n", format(Sys.time(), "%H:%M:%S")))
for (i in seq_len(ncol(taxa))) {
  assigned <- sum(!is.na(taxa[, i]))
  cat(sprintf("  %-10s %d / %d (%.1f%%)\n",
              colnames(taxa)[i], assigned, nrow(taxa),
              assigned / nrow(taxa) * 100))
}

# ── Export tables ──────────────────────────────────────────────────────────
cat(sprintf("[%s] Exporting final tables...\n", format(Sys.time(), "%H:%M:%S")))

# Sequences come from seqtab.nochim column names (not taxa rownames, which can
# be truncated by some R versions when stored as a matrix)
all_seqs <- colnames(seqtab.nochim)
n_asvs   <- length(all_seqs)
stopifnot(nrow(taxa) == n_asvs)   # sanity: taxa and seqtab must have same ASV count

taxa_df <- as.data.frame(taxa, stringsAsFactors = FALSE)
taxa_df$ASV <- paste0("ASV", seq_len(n_asvs))
taxa_df$SEQ <- all_seqs
rownames(taxa_df) <- taxa_df$ASV

# Correspondence table: ASV label <-> full DNA sequence
correspondence <- taxa_df[, c("ASV", "SEQ")]
write.table(correspondence,
            file.path(outdir, "Tables", paste0("correspondence_table_", RUN_ID, ".txt")),
            sep = "\t", quote = FALSE, row.names = FALSE, col.names = TRUE)

# Taxonomy table: ASV rows, rank columns (Kingdom through Species)
taxa_mat <- as.matrix(taxa_df[, !colnames(taxa_df) %in% c("ASV", "SEQ")])
write.table(taxa_mat,
            file.path(outdir, "Tables", paste0("taxonomy_table_", RUN_ID, ".txt")),
            sep = "\t", quote = FALSE, row.names = TRUE, col.names = TRUE)

# Abundance table: ASV rows, sample columns
# Rows renamed by position (safe — assignTaxonomy preserves seqtab column order)
otu <- t(seqtab.nochim)
rownames(otu) <- taxa_df$ASV
otu <- as.matrix(otu)
class(otu) <- "numeric"
write.table(otu,
            file.path(outdir, "Tables", paste0("abundance_table_", RUN_ID, ".txt")),
            sep = "\t", quote = FALSE, row.names = TRUE, col.names = TRUE)

cat(sprintf("[%s] Done. Final: %d samples x %d ASVs\n",
            format(Sys.time(), "%H:%M:%S"), ncol(otu), nrow(otu)))
cat(sprintf("  Taxonomy:      %s\n",
            file.path(outdir, "Tables", paste0("taxonomy_table_",     RUN_ID, ".txt"))))
cat(sprintf("  Abundance:     %s\n",
            file.path(outdir, "Tables", paste0("abundance_table_",    RUN_ID, ".txt"))))
cat(sprintf("  Correspondence:%s\n",
            file.path(outdir, "Tables", paste0("correspondence_table_",RUN_ID, ".txt"))))
