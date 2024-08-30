import pysam
import argparse

parser=argparse.ArgumentParser(description= """
            Description
            -----------
            Python script that adds a tag before the bam file cell barcode

            Authors
            -----------
            Vlachos Christos""",formatter_class=argparse.RawDescriptionHelpFormatter)


parser.add_argument("--bam",type=str, required=True,dest="bam",default=None, help="Bam output file from cell ranger")
parser.add_argument("--string", type=str,required=True, dest="toadd", default=None, help="String to add in every CB")
parser.add_argument("--out",type=str, required=True,dest="out",default=None, help="Bam output file")

args = parser.parse_args()

input_bam=args.bam
out_bam=args.out

samfile = pysam.AlignmentFile(input_bam, "rb")

with pysam.AlignmentFile(out_bam, "wb", template=samfile) as outf:
	for read in samfile.fetch():
		a=pysam.AlignedSegment(samfile.header)

		if read.has_tag('CB'):
			CB=read.get_tag('CB')
			newCB=args.toadd+'_'+CB
			read.set_tag('CB', newCB)			

			a.query_name = read.query_name
			a.query_sequence = read.query_sequence
			a.reference_name = read.reference_name
			a.flag = read.flag
			a.reference_start = read.reference_start
			a.mapping_quality = read.mapping_quality
			a.cigar = read.cigar
			a.next_reference_id = read.next_reference_id
			a.next_reference_start = read.next_reference_start
			a.template_length = read.template_length
			a.query_qualities = read.query_qualities
			a.tags = read.tags

			outf.write(a)	

outf.close()
