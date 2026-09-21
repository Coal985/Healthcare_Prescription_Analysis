# Determinants of Prescription Costs: A Multivariate Analysis of Out-of-Pocket Drug Spending

A healthcare analytics course project (BUS 626, Advanced Healthcare Analytics, SUNY New Paltz, Spring 2026) that uses 2023 Medical Expenditure Panel Survey (MEPS) data to study which demographic, socioeconomic, and geographic factors are most strongly associated with what patients pay out of pocket for prescriptions in the United States. Data preparation is done in Python, and the regression modeling is done in R using a log-linear OLS model with patient-clustered standard errors.

**Author:** Cole Potrzeba. The full presentation is in [`docs/`](docs/).

## Motivation

Prescription costs are a real burden for many Americans. U.S. healthcare spending reached $4.9 trillion in 2023, retail prescription drug spending grew 11.4% that year, and about 1 in 4 Americans report struggling to afford their prescriptions. Cost-related non-adherence is estimated to contribute to around 100,000 preventable deaths and $100 billion in avoidable medical costs each year, and patients with chronic conditions like diabetes, hypertension, and heart disease face the greatest risk.

This project asks: *what demographic, socioeconomic, and geographic factors are most strongly associated with variation in prescription costs in the United States?* The goal was to identify who pays the most and where policy could reduce the burden.

## Data & Methods

- **Sources:** Two 2023 MEPS public-use files from the Agency for Healthcare Research and Quality (AHRQ): **HC-248A** (Prescribed Medicines, one row per prescription fill) and **HC-251** (Full Year Consolidated, person-level demographics, insurance, and health conditions). They were merged on the unique patient identifier `DUPERSID`.
- **Outcome:** Patient out-of-pocket payment per prescription fill (`RXSLF23`), log-transformed to handle its heavy right skew.
- **Cleaning (Python):** Survey codes were recoded into readable categories, negative codes were treated as missing, and therapeutic drug class codes were collapsed into five clinical groups (cardiovascular, metabolic, mental health, respiratory, other). Records with $0 out-of-pocket payments were excluded, the sample was restricted to adults (18+), and rows with missing values in the selected variables were dropped.
- **Final dataset:** 161,647 prescription-level records. The unit of analysis is an individual prescription fill.
- **Predictors:** Age, sex, race/ethnicity, insurance type, income (poverty category), Census region, therapeutic class, and four chronic condition flags (high blood pressure, diabetes, heart disease, asthma).
- **Reference group:** A poor white female with public insurance in the South, filling an "other" class drug, with no chronic conditions.
- **Model (R):** OLS regression of log out-of-pocket cost on the 11 predictors, with standard errors clustered at the patient level (`sandwich` and `lmtest`), since the same patient can appear on many rows.
- **Diagnostics:** Multicollinearity checked with generalized variance inflation factors (`car`), which are appropriate for multi-level categorical variables. All GVIF^(1/(2·Df)) values were between 1.02 and 1.15, well below the concern threshold of 2.

| Dataset Snapshot                         | Value                              |
| ---------------------------------------- | ---------------------------------- |
| Records                                  | 161,647 prescription fills         |
| Mean age                                 | 61.6 years (SD 15.1)               |
| Race / ethnicity                         | ~81% White, ~13% Black, ~3% Asian / Pacific Islander |
| Insurance                                | ~52% private, ~47% public, ~1% uninsured |
| Chronic conditions                       | 67% high blood pressure, 32% diabetes, 23% asthma, 15% heart disease |

## Key Results

Because the outcome is log-transformed, coefficients are read as approximate percent changes in out-of-pocket cost per fill: (exp(β) − 1) × 100.

| Predictor (vs. reference)       | Coefficient | Approx. Effect on OOP Cost | Significance |
| ------------------------------- | ----------- | -------------------------- | ------------ |
| Uninsured (vs. public)          | +1.016      | ~2.8× higher               | p < 0.001    |
| Private insurance (vs. public)  | +0.545      | ~72% higher                | p < 0.001    |
| Diabetes                        | +0.538      | ~71% higher                | p < 0.001    |
| Heart disease                   | +0.245      | ~28% higher                | p < 0.01     |
| Asthma                          | +0.235      | ~27% higher                | p < 0.001    |
| Age (per year)                  | +0.022      | ~2.2% higher per year      | p < 0.001    |
| Middle income (vs. poor)        | +0.856      | ~2.4× higher               | p < 0.001    |
| High income (vs. poor)          | +0.998      | ~2.7× higher               | p < 0.001    |
| Asian / Pacific Islander (vs. White) | −0.773 | ~54% lower                 | p < 0.001    |
| Black / African American (vs. White) | −0.316 | ~27% lower                 | p < 0.001    |
| Northeast (vs. South)           | −0.142      | ~13% lower                 | p < 0.05     |
| West (vs. South)                | −0.172      | ~16% lower                 | p < 0.05     |
| Cardiovascular drug class (vs. other) | −0.163 | ~15% lower                | p < 0.001    |
| Metabolic drug class (vs. other) | −0.126     | ~12% lower                 | p < 0.001    |

Sex, high blood pressure, the American Indian and multiple-race categories, respiratory drug class, and near-poor income were not statistically significant. Low income was significant (+0.396, p < 0.001), and mental health drug class was modestly higher (+0.083, p < 0.05).

## Key Findings

- **Insurance type is the dominant predictor.** Uninsured patients pay about 2.8 times more per fill than publicly insured patients, and privately insured patients pay about 72% more, which points to public coverage (Medicare and Medicaid) as the strongest reducer of out-of-pocket drug costs in this analysis.
- **Diabetes, heart disease, and asthma each raise costs significantly,** while high blood pressure does not. The large diabetes premium is consistent with published evidence on high out-of-pocket costs for insulin and diabetes supplies.
- **Out-of-pocket costs rise with income.** Wealthier patients are more likely to have private insurance with cost-sharing, and may fill more prescriptions, whereas Medicaid limits what low-income patients pay.
- **The South has the highest costs.** The Northeast and West are significantly cheaper, and the Midwest is essentially the same as the South (−0.008).
- **Asian / Pacific Islander and Black patients pay less per fill.** This may partly reflect lower prescription utilization due to access barriers rather than a lower cost burden overall, which the data here cannot confirm.

## Limitations

- **Excluding $0 payments may bias results.** 36.3% of uninsured records had $0 out-of-pocket cost (versus 18.7% of public and 7.7% of private), so dropping them likely shrinks the uninsured coefficient.
- **Prescription details are unobserved.** Days supply, pill count, and dosage strength directly affect cost and are not in the model. Therapeutic class is included as a control, but variation within a class remains.
- **Age is capped at 85** in the public-use file, which may understate the effect of advanced age.
- **Small uninsured group.** Only 1,891 records (about 1%) are uninsured, so that estimate rests on a small share of the sample.
- **Cost per fill, not total burden.** The unit is a single prescription fill, so the analysis does not capture annual spending or fills that patients skipped because of cost.
- **No survey weights.** The models are unweighted, so results describe this sample rather than weighted national estimates.
- **Association, not causation.** This is an observational analysis of survey data, and the coefficients should not be read as causal effects.

## Future Work

Include $0-payment fills with a two-part model, add survey weights, control for days supply and dosage, and look at annual per-person spending and cost-related non-adherence.

## Skills Demonstrated

Merging and cleaning large survey datasets in pandas · recoding survey codes and collapsing categories · log transformation for skewed outcomes · multivariate regression with clustered standard errors in R · reference-category coding · multicollinearity diagnostics (GVIF) · interpreting log-linear coefficients as percent effects · literature review · connecting statistical findings to policy implications

## Tools & Stack

Python (pandas, NumPy, Matplotlib, seaborn) · R (`sandwich`, `lmtest`, `car`) · Jupyter · MEPS public-use data

## Repository Contents

- `HCA_Py.ipynb`: data loading, merging, cleaning, recoding, log transformation, and descriptive statistics
- `Model_R.R`: regression model, clustered standard errors, and GVIF diagnostics
- `docs/HCA_Project_Final.pdf`: final presentation slides

## Running It

1. Download the 2023 MEPS files [HC-248A](https://meps.ahrq.gov/mepsweb/data_stats/download_data_files_detail.jsp?cboPufNumber=HC-248A) and [HC-251](https://meps.ahrq.gov/mepsweb/data_stats/download_data_files_detail.jsp?cboPufNumber=HC-251) and save them as `h248a.csv` and `h251.csv` next to the notebook. The raw data is not included in this repository.
2. Run `HCA_Py.ipynb` to produce `my_data.csv`. It needs `pandas`, `numpy`, `matplotlib`, and `seaborn`.
3. Open `Model_R.R` and change the `read.csv(...)` path at the top so it points to your `my_data.csv`. It needs the R packages `sandwich`, `lmtest`, and `car`.
4. Run the script to fit the model, print the clustered-standard-error coefficient table, and print the GVIF values.

## Sources

- Agency for Healthcare Research and Quality. 2023 Prescribed Medicines (HC-248A) and 2023 Full Year Consolidated Data File (HC-251), Medical Expenditure Panel Survey.
- Amin, K., et al. [Availability and Variation of Publicly Reported Prescription Drug Prices](https://www.ajmc.com/view/availability-and-variation-of-publicly-reported-prescription-drug-prices). *American Journal of Managed Care*, 2023.
- Bui, C. N., et al. [Trends and Determinants of Retail Prescription Drug Costs](https://pmc.ncbi.nlm.nih.gov/articles/PMC9108059/). *Pharmacotherapy*, 2022.
- Gellad, W. F., et al. Prescription Drug Cost Sharing: Associations with Medication and Medical Utilization and Spending and Health. *Annual Review of Public Health*, 2017.
- Xu, X., et al. [Per-Prescription Drug Expenditure by Source of Payment and Income Level in the United States, 1997 to 2015](https://pubmed.ncbi.nlm.nih.gov/31426927/). *Medical Care*, 2019.
- National Health Expenditure Accounts Team. [National Health Expenditures in 2023](https://www.cms.gov/data-research/statistics-trends-and-reports/national-health-expenditure-data/nhe-fact-sheet). *Health Affairs*, 2024.
- National Pharmaceutical Council. [Racial and Ethnic Disparities in Prescription Drug Utilization and Spending](https://www.npcnow.org/resources/new-study-reveals-significant-racial-and-ethnic-disparities-prescription-drug-utilization), 2025.
- Magellan Health. [Prescription Predicament: The Impact of Rising Drug Costs on Medication Adherence](https://www.magellanhealthinsights.com/2024/02/19/prescription-predicament-the-impact-of-rising-drug-costs-on-medication-adherence/), 2024.
- CDC National Center for Health Statistics, *Cost-Related Prescription Drug Nonadherence Among Adults: United States, 2021*, and Kirzinger, A., et al., *Americans' Challenges with Health Care Costs*, KFF Health Tracking Poll, 2022.
- Fox, J., and Monette, G. (1992). Generalized collinearity diagnostics. *Journal of the American Statistical Association*.
