function [structStat] = correlPlot(essaiA,essaiB,cond)
% CORRELPLOT compares 2 dataset with correlation analysis
%   correlPlot(essaiA,essaiB) plot scatter data, identity line and fitting line
%
%   essaiA and essaiB must be a column or a line with observations.
%
%   correlPlot(essaiA,essaiB,cond) specifies the paramaters displayed in a box next to the plot
%   'valid' allows you to see Typical Error of Estimate, Coefficient of
%   determination, mean bias, number of observations, Pearson's r
%   'repro' allows you to see ICC and CI95% and Typical Error of Measurement and SWC and its sensitivity (Hopkins, 2015)
%   By default cond = 'valid'
%
%   [structStat] = correlPlot(essaiA,essaiB,cond) returns a structure
%   object with statistical parameters displayed on the plot.
%
%   See also SCATTER, FITLM, LINE.
%   @MatPab

switch nargin
    case 2
        cond  = "valid";
end

col  =    [0.2510         0    0.2941
    0.4627    0.1647    0.5137
    0.6000    0.4392    0.6706
    0.7608    0.6471    0.8118
    0.9059    0.8314    0.9098
    0.9686    0.9686    0.9686
    0.8510    0.9412    0.8275
    0.6510    0.8588    0.6275
    0.3529    0.6824    0.3804
    0.1059    0.4706    0.2157
    0    0.2667    0.1059];

%% Correlation (validité ou reproductibilité)
[nbSuj,~] = size(essaiA);

mdl = fitlm(essaiA,essaiB);
r_squared = mdl.Rsquared.Ordinary;
coeff = mdl.Coefficients.Estimate;

scatter(essaiA,essaiB,35,[0.4627    0.25    0.5137],'filled')
hold on
lim  = ceil(max([essaiA essaiB],[],'all'))+0.05*max([essaiA essaiB],[],'all');
plot([0 lim],[0 lim],'Color',col(end-1,:),'LineStyle','--','LineWidth',2)
f_fitV0 = @(x) coeff(2)*x+coeff(1);
fplot(f_fitV0,[0 lim],'Color',col(4,:),'LineWidth',2)
ylim([min([essaiA essaiB],[],'all')-0.1*max([essaiA essaiB],[],'all') lim])
xlim([min([essaiA essaiB],[],'all')-0.1*max([essaiA essaiB],[],'all') lim])

yt = get(gca, 'YTick');
set(gca, 'XTick',yt(1:2:end),'YTick',yt(1:2:end))
pearsonR = corrcoef(essaiA,essaiB);


if strcmpi(cond,'valid')
    
    TEE = std(diff([essaiA essaiB],1,2));                                   % Hopkins (2009): Typical Error of Estimate
    TEE100= TEE/mean(essaiA)*100;                                           % TEE as coefficient of variation (%)
    
    CV = std([essaiA essaiB],0,2)./mean([essaiA essaiB],2);                 % CV melange erreur aleatoire et systematique
    dataCI = CV;
    SEMM = std(dataCI)./sqrt(length(dataCI));                             
    ts = tinv([0.05  0.95],length(dataCI)-1);                               
    CI = mean(dataCI)' + ts.*SEMM';                                         % Confidence Intervals
    CV = mean(CV);
    
    str = {sprintf('n = %d',nbSuj), sprintf('bias = %1.2f',diff(mean([essaiA essaiB]))),sprintf('TEE = %1.2f',TEE),strcat('TEE\%',sprintf(' = %1.2f',TEE100)), sprintf('r = %1.3f', pearsonR(2)), strcat("$r^2$",sprintf(' = %1.3f',r_squared)),sprintf('y = %1.2fx+%1.2f',coeff(2),coeff(1))};
    text(0.05,0.75,str,'Units','normalized','Interpreter','latex','FontSize',9,'Color',[.2 .2 .2])
%     text(0.05,0.95,str(end),'Units','normalized','Interpreter','latex','FontSize',9,'Color',[.2 .2 .2])
    hold off
    xlabel('Criterion','Interpreter','latex')
    ylabel('Practical','Interpreter','latex')
    
    structStat.TEE = TEE;
    structStat.TEE100 = TEE100;
    structStat.R2 = r_squared;
    structStat.Bias = diff(mean([essaiA essaiB]));
    structStat.Pente = sprintf('y = %1.2fx+%1.2f',coeff(2),coeff(1));
    structStat.pearsonR = pearsonR(2);
   	structStat.coeffVar.CV = CV;
    structStat.coeffVar.CI = CI;
elseif strcmpi(cond,'repro')
   
    [n, k] = size([essaiA essaiB]);
    SStotal = var([essaiA essaiB]) *(n*k - 1);
    MSR = var(mean([essaiA essaiB], 2)) * k;
    MSC = var(mean([essaiA essaiB], 1)) * n;
    MSE = (SStotal - MSR *(n - 1) - MSC * (k -1))/ ((n - 1) * (k - 1));

    [iccData, lbData, ubDaat] = ICC_repro(MSR, MSE, MSC, 0.05, n, k);       % McGraw and Wong (1996): Two-way mixed effects, absolute agreement, single rater/measurement ICC
    
    TEM = std(diff([essaiA essaiB],1,2))/sqrt(2);                           % Hopkins 2009: Typical Error of Measurement
    TEM100 = TEM/mean(essaiA)*100;                                          % TEM as coefficient of variation (%)
    
%     SDo = std(essaiA);                                                    
%     SDp = SDo*sqrt(iccData);
    SDp = std(essaiA);
    SWC = SDp*0.2;                                                          % Hopkins 2015: dans sa fiche excel
    
    sensi = TEM100>SWC;
    switch sensi
        case 1
            sensibility = ' (poor)';
        case 0
            sensibility = ' (good)';
    end
    
    
    str = {sprintf('n = %d',nbSuj), sprintf('TEM = %1.2f', TEM),strcat('TEM\%',sprintf(' = %1.2f',TEM100)),sprintf('$ICC_{2,1} = %1.3f$ (%1.2f ; %1.2f)',iccData,lbData,ubDaat), sprintf('r = %1.3f', pearsonR(2)), strcat(sprintf('SWC = %1.2f',SWC),sensibility),sprintf('y = %1.2fx+%1.2f',coeff(2),coeff(1))};
    text(0.05,0.75,str,'Units','normalized','Interpreter','latex','FontSize',9,'Color',[.2 .2 .2])
    hold off
    xlabel('Test','Interpreter','latex')
    ylabel('Retest','Interpreter','latex')
    
        
    structStat.ICC = iccData;
    structStat.ICC_IC95 = [lbData ubDaat];
    structStat.R2 = r_squared;
    structStat.Bias = diff(mean([essaiA essaiB]));
    structStat.Pente = sprintf('y = %1.2fx+%1.2f',coeff(2),coeff(1));
    structStat.pearsonR = pearsonR(2);
   	structStat.TEM = TEM;
   	structStat.TEM100 = TEM100;
    structStat.SWC = SWC;
else
    error('Third input must be "valid" or "repro" or not specified (default condition = "valid")')
    
end

    hfig= gcf;  % save the figure handle in a variable
    
    picturewidth = 18; % set this parameter and keep it forever
    hw_ratio = .8333; % feel free to play with this ratio
    set(findall(hfig,'-property','FontSize'),'FontSize',17) % adjust fontsize to your document
    
    set(findall(hfig,'-property','Box'),'Box','off') % optional
    set(findall(hfig,'-property','Interpreter'),'Interpreter','latex')
    set(findall(hfig,'-property','TickLabelInterpreter'),'TickLabelInterpreter','latex')
    set(hfig,'Units','centimeters','Position',[3 3 picturewidth hw_ratio*picturewidth])
    pos = get(hfig,'Position');
    set(hfig,'PaperPositionMode','Auto','PaperUnits','centimeters','PaperSize',[pos(3), pos(4)])



function [r, LB, UB] = ICC_repro(MSR, MSE, MSC, alpha, n, k)
    % function ICC by (c) Arash Salarian, 2008
r = (MSR - MSE) / (MSR + (k-1)*MSE + k*(MSC-MSE)/n);

a = k*r/(n*(1-r));
b = 1+k*r*(n-1)/(n*(1-r));
v = (a*MSC + b*MSE(1))^2/((a*MSC)^2/(k-1) + (b*MSE(1))^2/((n-1)*(k-1)));

Fs = finv(1-alpha/2, n-1, v);
LB = n*(MSR - Fs*MSE)/(Fs*(k*MSC + (k*n - k - n)*MSE) + n*MSR);
Fs = finv(1-alpha/2, v, n-1);
UB = n*(Fs*MSR-MSE)/(k*MSC + (k*n - k - n)*MSE + n*Fs*MSR);
end


end