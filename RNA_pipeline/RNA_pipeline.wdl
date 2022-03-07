import "star_v1-0_BETA_cfg.wdl" as star_v1
import "rnaseqc2_v1-0_BETA_cfg.wdl" as rnaseqc2_v1
import "rsem_depmap.wdl" as rsem_v1


workflow RNA_pipeline {

  File star_index # STAR_genome_GRCh38_noALT_noHLA_noDecoy_ERCC_v29_oh100.tar.gz
  File fastq1
  File fastq2
  File genes_gtf
  String sample_id

  call star_v1.star as star {
    input:
      prefix=sample_id,
      fastq1=fastq1,
      fastq2=fastq2,
      star_index = star_index
  }

  call rnaseqc2_v1.rnaseqc2 as rnaseqc2 {
    input:
      bam_file=star.bam_file,
      genes_gtf=genes_gtf,
      sample_id=sample_id
  }

  call rsem_v1.rsem as rsem {
    input:
      transcriptome_bam=star.transcriptome_bam,
      prefix=sample_id,
      is_stranded="false",
      paired_end="true"
  }

  output {
    #samtofastq
    #star
    File bam_file=star.bam_file
    File bam_index=star.bam_index
    File transcriptome_bam=star.transcriptome_bam
    File chimeric_junctions=star.chimeric_junctions
    File chimeric_bam_file=star.chimeric_bam_file
    File read_counts=star.read_counts
    File junctions=star.junctions
    File junctions_pass1=star.junctions_pass1
    Array[File] logs=star.logs
    #rnaseqc
    File gene_tpm=rnaseqc2.gene_tpm
    File gene_counts=rnaseqc2.gene_counts
    File exon_counts=rnaseqc2.exon_counts
    File metrics=rnaseqc2.metrics
    File insertsize_distr=rnaseqc2.insertsize_distr
    #rsem
    File genes=rsem.genes
    File isoforms=rsem.isoforms
  }
}

