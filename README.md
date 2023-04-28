# plotReliabilityValidity
Quickly plot correlation plots for validity and reliability studies with associated statistics

______________________________________
**Validity**
- bias: 
$$bias = \overline{X_p} - \overline{X_c}$$  
$$bias 100 = \frac{\overline{X_p} - \overline{X_c}}{\overline{X_c}}\cdot 100$$
With $\overline{X_c}$ and $\overline{X_p}$ being the average of the criterion and practical group, respectively.

- TEE (Typical Error of Estimate) based on Siegel and al. (2016) and Hopkins (2015)
$$TEE = \sigma_c\cdot\sqrt{(1-r^2)\frac{n-1}{n-2}}$$
- TEE%: TEE as coefficient of variation (CV) in %   
$$CV = \frac{TEE \cdot 100}{\overline{X_c}}$$
- r: Pearson's r 
```ruby
pearsonR = corrcoef(criterion,practical)
% see doc corrcoef for more infos
```


![alt text](https://github.com/PabRD/plotReliabilityValidity/blob/main/gitHub_ExempleValidity.png)


___________________________________
**Reliability**
- TEM (Typical Error of Measurement) (Hopkins, 2015)
$$TEM = \frac{{\sigma}_{diff}}{\sqrt{2}}$$
- TEM%: TEM as coefficient of variation (CV) in %
$$CV = \frac{TEM \cdot 100}{\overline{X_1}}$$
- ICC (Intraclass Correlation Coefficients): Reported as "ICC2,1" (Shrout and Fleiss convention) or "Two-way mixed effects, absolute agreement, single rater/measurement" (McGraw and Wong convention) for test-retest reliability study (Koo and Li, 2016).
$$ICC_{2,1} = \frac{MS_R-MS_E}{MS_R+(k-1)MS_E+\frac{k}{n}(MS_C-MS_E)}$$
with $MS_R = mean\ square\ for\ rows$, $MS_E=mean\ square\ for\ error$; $MS_C=mean\ square\ for\ columns$; $n =number\ of\ subjects$; $k = number\ of\ raters/measurements$.
- r: Pearson's r
- SWC (Smallest Worthwile Change): 0.2 times the between participant standard deviation. Sensitivity is classified as good when TEM as CV% is inferior to SWC. Otherwise, sensitivity is classified as poor
$$SWC = 0.2\cdot\sigma_1$$
with $\sigma_1 = standard\ deviation\ of\ first\ test$


![alt text](https://github.com/PabRD/plotReliabilityValidity/blob/main/gitHub_ExempleReliability.png)

__________________________________

Koo, T. K., & Li, M. Y. (2016). A Guideline of Selecting and Reporting Intraclass Correlation Coefficients for Reliability Research. Journal of Chiropractic Medicine, 15(2), 155–163. https://doi.org/10.1016/j.jcm.2016.02.012 

Hopkins, W. G. (2015). Spreadsheets for Analysis of Validity and reliability. Sportsscience 19, 36-44.

Shrout, P. E., & Fleiss, J. L. (1979). Intraclass correlations: uses in assessing rater reliability.1. Shrout PE, Fleiss JL: Intraclass correlations: uses in assessing rater reliability. Psychol Bull 1979, 86:420–8. Psychological Bulletin, 86(2), 420–428. http://www.ncbi.nlm.nih.gov/pubmed/18839484

McGraw, K. O., & Wong, S. P. (1996). “Forming inferences about some intraclass correlations coefficients”: Correction. Psychological Methods, 1(4), 390–390. https://doi.org/10.1037//1082-989x.1.4.390

Siegel and al. (2016) Practical Business Statistics (Sixth Edition), page 325
