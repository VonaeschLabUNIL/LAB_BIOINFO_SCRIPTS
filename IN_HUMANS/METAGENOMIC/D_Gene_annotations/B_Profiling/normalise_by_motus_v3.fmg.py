import sys
import glob

fmg_folder = sys.argv[1]
profile_file = sys.argv[2]
output_profile_file = profile_file + '.cellab.profile'
import collections

def calc_motu_mg_median(profile_file, fmg_folder, name_column=0, cog_column=4):
    motus_cogs = set(['COG0012','COG0016','COG0018','COG0172','COG0215','COG0495','COG0525','COG0533','COG0541','COG0552'])
    gene_2_cog = {}
    for motus_cog in motus_cogs:
        cog_file = fmg_folder + '/' + motus_cog + '.fna'
        with open(cog_file) as handle:
            for line in handle:
                if line.startswith('>'):
                    seqid = line[1:].split()[0]
                    gene_2_cog[seqid] = motus_cog
    #with open(annotation_filei) as handle: # this is the kegg file which is now the fmg folder
    #    for line in handle:
    #        splits = line.strip().split()
    #        
    #
    #        if len(splits) <  (max(cog_column, name_column) + 1):
    #            continue
    #        gene = splits[name_column]
    #        cog = splits[cog_column]
    #        multicog = set()
    #        for c in cog.split('---'):
    #            for cc in c.split(';'):
    #                ccc = cc.replace('cog:', '')
    #                multicog.add(ccc)
    #        for mc in multicog:
    #            if mc in motus_cogs:
    #                gene_2_cog[gene] = mc
    cnter = collections.Counter(gene_2_cog.values())
    
    print('MG\tNumber of Genes')
    for motu_cog in motus_cogs:
        print(f'{motu_cog}\t{cnter[motu_cog]}')
    
    if len(cnter) != len(motus_cogs):
        print('ERROR: Some genes used for normalising were not detected.')
        exit(1)
    header_lines = []
    sample_index = []
    sample_total_count = {}
    with open(profile_file) as handle:
 
        for line in handle:
            if line.startswith('#reference'):
                sample_index = line.strip().split('\t')[2:]
                for sample in sample_index:
                    sample_total_count[sample] = 0
            elif line.startswith('#'):
                header_lines = line.strip()
            else:
                splits = line.strip().split('\t')
                gene = splits[0]
                for sample, count in zip(sample_index,splits[2:]):
                    if count != '0' or count != '0.00':
                        count = float(count)
                        sample_total_count[sample] += count
                if gene in gene_2_cog:
                    gene_2_cog[gene] = (gene_2_cog[gene], splits[2:])
    motus_cogs = sorted(list(motus_cogs))
    sample_2_motu_to_count = {}
    for sample in sample_index:
        sample_2_motu_to_count[sample] = {}
        for motu in motus_cogs:
            sample_2_motu_to_count[sample][motu] = 0

    for gene, motu_2_line in gene_2_cog.items():
        if len(motu_2_line) == 2:
            motu = motu_2_line[0]
            counts = motu_2_line[1]
            for sample, count in zip(sample_index, counts):
                count = float(count)
                sample_2_motu_to_count[sample][motu] += count
    sample_2_median_motu = {}

    for sample, motu_to_count in sample_2_motu_to_count.items():
        vals = sorted(list(motu_to_count.values()))
        median = (vals[4] + vals[5])/2
        if median < 1.0:
            median = 1.0
        total_count = sample_total_count[sample]
        sample_2_median_motu[sample] = (int(median), int(total_count), int(total_count / median))
    print('SAMPLE\tMEDIAN_MG_COUNT\tTOTAL_COUNT\tRATIO')
    for sample, data in sample_2_median_motu.items():
        print(f'{sample}\t{data[0]}\t{data[1]}\t{data[2]}')
    return sample_2_median_motu
sample_2_median_motu = calc_motu_mg_median(profile_file, fmg_folder, name_column=0, cog_column=4)

sample_index = []
def normalise_by_median(profile_file, sample_2_median_motu, output_profile_file):
    with open(output_profile_file, 'w') as outhandle:
        with open(profile_file) as inhandle:
                with open(profile_file) as handle:
 
                    for line in inhandle:
                        if line.startswith('#reference'):
                            sample_index = line.strip().split('\t')[2:]
                            outhandle.write(line.strip() + '\n')
                        elif line.startswith('#'):
                            outhandle.write(line.strip() + '; Normalised by median motu MG count --> normalised by cell abundance * 1000' + '\n')
                            
                        else:
                            splits = line.strip().split('\t')
                            gene = splits[0]
                            length = splits[1]
                            norm_counts = []
                            for sample, count in zip(sample_index,splits[2:]):
                                if count != '0' or count != '0.00':
                                    count = float(count)
                                    norm_count = '{0:.2f}'.format((1000.0 * count) / sample_2_median_motu[sample][0])
                                    norm_counts.append(norm_count)
                                else:
                                    norm_counts.append(count)
                            tmp1 = '\t'.join(norm_counts)
                            tmp = f'{gene}\t{length}\t{tmp1}\n'
                            outhandle.write(tmp)


normalise_by_median(profile_file, sample_2_median_motu, output_profile_file)
