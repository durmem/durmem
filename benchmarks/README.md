# Benchmark receipt

This directory is a partial reproducibility artifact for the benchmark figures
shown on durmem.ai. It makes the evaluated cohort and headline arithmetic
checkable without network access:

```sh
python3 benchmarks/verify_summary.py
```

The checker recomputes each rounded score from the disclosed numerator and
denominator in `summary.json` and checks that cohort and scope metadata are
present. It does **not** independently validate those counts or rerun ingestion,
model answers or judging. Those
steps require benchmark datasets, model access and private scored outcomes that
are not distributed in this repository, so calling this a full reproduction
would be misleading.

The disclosed scope is:

- STALE: 141 of 400 scenarios, with three scored dimensions per scenario
  (364/423 = 86.1%).
- LongMemEval: 149 questions across six categories (133/149 = 89.3%).
- AMA-Bench: 43 of 208 cases, 12 questions per case (390/516 = 75.6%).

STALE comparison numbers are durmem's same-cohort reference runs. LongMemEval and
AMA-Bench comparison numbers come from the corresponding benchmark papers; all
are context rather than a whole-field ranking:

- STALE benchmark paper (the reference numbers above are same-cohort reruns): <https://arxiv.org/abs/2605.06527>
- LongMemEval: <https://arxiv.org/abs/2410.10813>
- AMA-Bench: <https://arxiv.org/abs/2602.22769>
