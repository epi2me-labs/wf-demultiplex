#!/usr/bin/env python
"""Create workflow report."""

import argparse

from aplanat.report import WFReport


def main():
    """Run the entry point."""
    parser = argparse.ArgumentParser()
    parser.add_argument("report", help="Report output file")
    parser.add_argument("summary", help="Guppy demultiplexing summary file.")
    args = parser.parse_args()

    report = WFReport(
        "Read Demultiplexing Report", "wf-demultiplex")

    report.add_section()

    # write report
    report.write(args.report)


if __name__ == "__main__":
    main()
