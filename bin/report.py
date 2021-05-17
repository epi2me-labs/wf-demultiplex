#!/usr/bin/env python
"""Create workflow report."""

import argparse

from aplanat import bars
from aplanat.report import WFReport
from aplanat.util import Colors
import pandas as pd


def read_files(summaries, sep='\t'):
    """Read a set of files and join to single dataframe."""
    dfs = list()
    for fname in sorted(summaries):
        dfs.append(pd.read_csv(fname, sep=sep))
    return pd.concat(dfs)


def main():
    """Run the entry point."""
    parser = argparse.ArgumentParser()
    parser.add_argument("report", help="Report output file")
    parser.add_argument("summary", help="Guppy demultiplexing summary file.")
    args = parser.parse_args()

    report = WFReport(
        "Read Demultiplexing Report", "wf-demultiplex")

    section = report.add_section()
    section.markdown('''
### Summary
The chart below depicts simply the number of reads found for each barcode.
''')
    df = read_files([args.summary])
    counts = df.value_counts(subset=['barcode_arrangement']) \
        .reset_index().sort_values(by=['barcode_arrangement']) \
        .rename(columns={0: 'count'})
    plot = bars.simple_bar(
        counts['barcode_arrangement'].astype(str), counts['count'],
        colors=[Colors.cerulean]*len(counts),
        title='Number of reads per barcode.')
    plot.xaxis.major_label_orientation = 3.14/2
    section.plot(plot)

    # write report
    report.write(args.report)


if __name__ == "__main__":
    main()
