#!/bin/bash
###############################################################################
# SLURM submission script — DADA2 single batch
# UNIL Curnagl cluster
#
# USAGE
#   1. Edit the USER CONFIGURATION section below
#   2. Submit with: sbatch submit_dada2_run.sh
#   3. Monitor with: squeue -u YOUR_USERNAME
#   4. Check progress: tail -f LOGS_DIR/dada2_RUNID_JOBID.out
#
# RESUBMISSION AFTER FAILURE
#   The R script has checkpoints — completed steps are skipped automatically.
#   Just resubmit with the same command. To force a step to rerun, delete
#   the corresponding .rds file (see dada2_template.R header for details).
#
# RESOURCE GUIDELINES (adjust based on your sample count)
#   ~100 samples:   --time=0-05:00:00  --mem=32G
#   ~300 samples:   --time=0-10:00:00  --mem=64G
#   ~500 samples:   --time=0-18:00:00  --mem=96G
#   If you hit the memory limit, increase --mem and resubmit.
#   Check with: grep "Out of memory" LOGS_DIR/dada2_RUNID_*.err
###############################################################################

# ══════════════════════════════════════════════════════════════════════════════
# USER CONFIGURATION — edit this section before submitting
# ══════════════════════════════════════════════════════════════════════════════

#SBATCH --job-name=dada2_run1          # change to match your RUN_ID
#SBATCH --time=0-10:00:00              # adjust based on sample count (see above)
#SBATCH --cpus-per-task=16
#SBATCH --mem=64G                      # adjust based on sample count (see above)
#SBATCH --output=/scratch/YOUR_USERNAME/YOUR_PROJECT/logs/dada2_run1_%j.out
#SBATCH --error=/scratch/YOUR_USERNAME/YOUR_PROJECT/logs/dada2_run1_%j.err
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=your.email@unil.ch

# Path to the R script (must match RUN_ID set inside the R script)
RSCRIPT=/scratch/YOUR_USERNAME/YOUR_PROJECT/scripts/dada2_template.R

# Path to your R library (where dada2 are installed)
R_LIB=/scratch/YOUR_USERNAME/YOUR_PROJECT/R_LIB
# Julian's libraries can be used: /work/FAC/FBM/DMF/pvonaesc/vonasch_lab_general/jgarneau/R_LIBRARIES/
# dada2 version: 1.34.0

# ══════════════════════════════════════════════════════════════════════════════
# END USER CONFIGURATION
# ══════════════════════════════════════════════════════════════════════════════

set -eu

# Derived paths from SBATCH directives above
LOGS_DIR=$(dirname "${SBATCH_OUTPUT:-/scratch/YOUR_USERNAME/YOUR_PROJECT/logs/placeholder}")
RESULTS_DIR=$(dirname "$RSCRIPT")/../results

mkdir -p "$LOGS_DIR"

module load r-light
export R_LIBS_USER="$R_LIB"

echo "========================================"
echo "Job started:  $(date)"
echo "Host:         $(hostname)"
echo "CPUs:         ${SLURM_CPUS_PER_TASK}"
echo "Memory:       ${SLURM_MEM_PER_NODE} MB"
echo "R script:     $RSCRIPT"
echo "========================================"
echo ""

# ── Checkpoint status ────────────────────────────────────────────────────────
# Reads RUN_ID from the R script to find the correct results folder.
# Prints which steps will be skipped and which will run.
RUN_ID=$(grep '^RUN_ID' "$RSCRIPT" | head -1 | sed 's/.*"\(.*\)".*/\1/')
RESULTS="${RESULTS_DIR}/${RUN_ID}"

echo "=== Checkpoint status for ${RUN_ID} ==="

rds_check() {
  if [ -f "$1" ]; then echo "  [SKIP] $2"
  else                  echo "  [RUN]  $2"
  fi
}

# filterAndTrim: check if filtered folder has content
FILTDIR=$(grep '^BASE' "$RSCRIPT" | head -1 | sed 's/.*"\(.*\)".*/\1/')/data/${RUN_ID}/dada2_filtered
if [ -d "$FILTDIR" ] && [ "$(find "$FILTDIR" -name '*_F_filt.fastq.gz' -maxdepth 1 | wc -l)" -gt 0 ]; then
  echo "  [SKIP] filterAndTrim — filtered files found"
else
  echo "  [RUN]  filterAndTrim"
fi

rds_check "${RESULTS}/errF_${RUN_ID}.rds"                "learnErrors"
rds_check "${RESULTS}/seqtab_${RUN_ID}.rds"              "derep + dada + merge + seqtab"
rds_check "${RESULTS}/seqtab_nochim_${RUN_ID}.rds"       "chimera removal"
rds_check "${RESULTS}/taxa_${RUN_ID}.rds"                "assignTaxonomy + addSpecies"

if [ -f "${RESULTS}/Tables/abundance_table_${RUN_ID}.txt" ] && \
   [ -f "${RESULTS}/Tables/taxonomy_table_${RUN_ID}.txt" ]; then
  echo "  [DONE] All output tables exist — nothing to do"
  echo "         Delete ${RESULTS}/Tables/ to force re-export"
  echo ""
  exit 0
else
  echo "  [RUN]  Export tables"
fi
echo ""

# ── Run R script ─────────────────────────────────────────────────────────────
Rscript "$RSCRIPT"

echo ""
echo "========================================"
echo "Job finished: $(date)"
echo "========================================"
