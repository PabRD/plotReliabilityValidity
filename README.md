# plotReliabilityValidity
Quickly plot correlation plots for validity and reliability studies with associated statistics


```MATLAB
criterion = columVector1;     % criterion or first test data as a n by 1 column vector
practical = columVector2;     % practical or retest data as a n by 1 column vector

recapStatValid = correlPlot(criterion,practical,'valid');
recapStatRepro = correlPlot(criterion,practical,'repro');
% see help correlPlot or the exemple file provided "utilisationCorrelPlot.m" for more infos
```

______________________________________

## Validity

- bias: 
$$bias = \overline{X_p} - \overline{X_c}$$  
$$bias 100 = \frac{\overline{X_p} - \overline{X_c}}{\overline{X_c}}\cdot 100$$
With $\overline{X_c}$ and $\overline{X_p}$ being the average of the criterion and practical group, respectively.

- TEE (Typical Error of Estimate) alos called Standard Error of Estimate (SEE) based on Siegel and al. (2016) and Hopkins (2015)
$$TEE = \sigma_c\cdot\sqrt{(1-r^2)\frac{n-1}{n-2}}$$

with $\sigma_c$ the standard deviation of the criterion group, $r$ the coefficient of correlation and $n$ the sample size
- TEE%: TEE as coefficient of variation (CV) in %   
$$CV = \frac{TEE \cdot 100}{\overline{X_c}}$$
- TEE 95% Confidence intervals are calculated as:
$$\sqrt{\frac{(n-1)s^2}{\chi^2_1}} < \sigma < \sqrt{\frac{(n-1)s^2}{\chi^2_2}}$$
with $s=TEE$ and $\chi^2$ probability calculated using ``chi2inv`` function

- r: Pearson's coefficient of correlation
```MATLAB
pearsonR = corrcoef(criterion,practical)
% see doc corrcoef for more infos
```


![alt text](https://github.com/PabRD/plotReliabilityValidity/blob/main/gitHub_ExempleValidity.png)


___________________________________
## Reliability
- TEM (Typical Error of Measurement), also called Standard Error of Measurement (SEM) (Hopkins, 2015)
$$TEM = \frac{{\sigma}_{diff}}{\sqrt{2}}$$
- TEM%: TEM as coefficient of variation (CV) in %
$$CV = \frac{TEM \cdot 100}{\overline{X_1}}$$
- TEM 95% Confidence intervals are calculated as:
$$\sqrt{\frac{(n-1)s^2}{\chi^2_1}} < \sigma < \sqrt{\frac{(n-1)s^2}{\chi^2_2}}$$
with $s = TEM$, $n = sample size$ and $\chi^2$ probability calculated using ``chi2inv`` function
- ICC (Intraclass Correlation Coefficients): Reported as "ICC2,1" (Shrout and Fleiss convention) or "Two-way mixed effects, absolute agreement, single rater/measurement" (McGraw and Wong convention) for test-retest reliability study (Koo and Li, 2016).
$$ICC_{2,1} = \frac{MS_R-MS_E}{MS_R+(k-1)MS_E+\frac{k}{n}(MS_C-MS_E)}$$
with $MS_R = mean\ square\ for\ rows$, $MS_E=mean\ square\ for\ error$; $MS_C=mean\ square\ for\ columns$; $n =number\ of\ subjects$; $k = number\ of\ raters/measurements$.

<details>

<summary>Why $ICC_{2,1}$ for test-retest studies ?</summary>
"The only question to ask is whether the actual application will be based on a single measurement or the mean of multiple measurements. As for the “Model” selection, Shrout and Fleiss suggest that 2-way mixed-effects model is appropriate for testing intrarater reliability with multiple scores from the same rater, as it is not reasonable to generalize one rater’s scores to a larger population of raters. Similarly, 2-way mixed-effects model should also be used in test-retest reliability study because repeated measurements cannot be regarded as randomized samples. In addition, absolute agreement definition should always be chosen for both test-retest and intrarater reliability studies because measurements would be meaningless if there is no agreement between repeated measurements." Koo & Li (2016)

</details>


- r: Pearson's coefficient of correlation
- SWC (Smallest Worthwile Change): Sensitivity is classified as good when TEM is inferior to SWC. Otherwise, sensitivity is classified as poor
$$SWC = 0.2\cdot\sigma_1$$
with $\sigma_1 = between\ particpant\ standard\ deviation\ of\ first\ test$


![alt text](https://github.com/PabRD/plotReliabilityValidity/blob/main/gitHub_ExempleReliability.png)

__________________________________

Koo, T. K., & Li, M. Y. (2016). A Guideline of Selecting and Reporting Intraclass Correlation Coefficients for Reliability Research. Journal of Chiropractic Medicine, 15(2), 155–163. https://doi.org/10.1016/j.jcm.2016.02.012 

Hopkins, W. G. (2015). Spreadsheets for Analysis of Validity and reliability. Sportsscience 19, 36-44.

Shrout, P. E., & Fleiss, J. L. (1979). Intraclass correlations: uses in assessing rater reliability.1. Shrout PE, Fleiss JL: Intraclass correlations: uses in assessing rater reliability. Psychol Bull 1979, 86:420–8. Psychological Bulletin, 86(2), 420–428. http://www.ncbi.nlm.nih.gov/pubmed/18839484

McGraw, K. O., & Wong, S. P. (1996). “Forming inferences about some intraclass correlations coefficients”: Correction. Psychological Methods, 1(4), 390–390. https://doi.org/10.1037//1082-989x.1.4.390

Siegel and al. (2016) Practical Business Statistics (Sixth Edition), page 325
