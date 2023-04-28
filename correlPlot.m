function [structStat] = correlPlot(criterion,essaiB,cond,color)
% CORRELPLOT compares 2 dataset with correlation analysis
%   correlPlot(criterion,essaiB) plot scatter data, identity line and fitting line
%
%   criterion and essaiB must be a column or a line with observations.
%
%   correlPlot(criterion,essaiB,cond) specifies the paramaters displayed in a box next to the plot
%   'valid' allows you to see Typical Error of Estimate, Coefficient of
%   determination, mean bias, number of observations, Pearson's r
%   'repro' allows you to see ICC and CI95% and Typical Error of Measurement and SWC and its sensitivity (Hopkins, 2015)
%   By default cond = 'valid'
%
%
%   correlPlot(criterion,essaiB,cond,color) use your own color with 2 colors : scatter data color with the first line and identity line & fitting line with last line color
%
%   [structStat] = correlPlot(criterion,essaiB,cond,col) returns a structure
%   object with statistical parameters displayed on the plot.
%
%   See also SCATTER, FITLM, LINE.
%   https://github.com/PabRD/plotReliabilityValidity/blob/main/README.md
%   @MatPab

col  =    [0 0 0; 0.7412 0.7412 0.7412];
colData = col(1,:);

if nargin==2
    
    cond  = "valid";
    
elseif nargin==4
    if size(color,1)==1
        col = color;
        colData = color;
    else
        col = color;
        colData = col(1,:);
    end
    
end


%% Correlation (validité ou reproductibilité)
[nbSuj,~] = size(criterion);

mdl = fitlm(criterion,essaiB);
r_squared = mdl.Rsquared.Ordinary;
coeff = mdl.Coefficients.Estimate;

if (coeff(1)>0)
    signe='+';
else
    signe='-';
end

% scatter(essaiA,essaiB,35,[0.4627    0.25    0.5137],'filled')
scatter(criterion,essaiB,35,colData(end,:),'filled','MarkerFaceAlpha',0.8)

hold on
lim  = ceil(max([criterion essaiB],[],'all'))+0.05*max([criterion essaiB],[],'all');
plot([0 lim],[0 lim],'Color',col(end,:),'LineStyle','--','LineWidth',2)
% plot([0 lim],[0 lim],'Color',col(4,:),'LineStyle','--','LineWidth',2)
f_fitV0 = @(x) coeff(2)*x+coeff(1);
fplot(f_fitV0,[0 lim],'Color',col(end,:),'LineWidth',2)
ylim([min([criterion essaiB],[],'all')-0.1*max([criterion essaiB],[],'all') lim])
xlim([min([criterion essaiB],[],'all')-0.1*max([criterion essaiB],[],'all') lim])

yt = get(gca, 'YTick');
set(gca, 'XTick',yt(1:2:end),'YTick',yt(1:2:end))
pearsonR = corrcoef(criterion,essaiB);


if strcmpi(cond,'valid')
    
    sY = std(criterion,'omitnan'); %sd criterion
    sEE = sY*(sqrt((1-mdl.Rsquared.Ordinary)*((nbSuj-1)/(nbSuj-2))));       % Siegel and al. (2016) Practical Business Statistics (Sixth Edition), page 325
    lB95 = sqrt((nbSuj-1)*sEE^2/(chi2inv(1-(1-0.95)/2,nbSuj-1)));
    uB95 = sqrt((nbSuj-1)*sEE^2/(chi2inv((1-0.95)/2,nbSuj-1)));
    
    
    %     TEE = std(diff([essaiA essaiB],1,2));                                   % Hopkins (2009): Typical Error of Estimate
    TEE = sEE;
    
    TEE100= TEE/mean(criterion)*100;                                           % TEE as coefficient of variation (%)
    
    CV = std([criterion essaiB],0,2)./mean([criterion essaiB],2);                 % CV melange erreur aleatoire et systematique
    dataCI = CV;
    SEMM = std(dataCI)./sqrt(length(dataCI));
    ts = tinv([0.05  0.95],length(dataCI)-1);
    CI = mean(dataCI)' + ts.*SEMM';                                         % Confidence Intervals
    CV = mean(CV);
    
    str = {sprintf('n = %d',nbSuj), sprintf('bias = %1.2f',diff(mean([criterion essaiB]))),sprintf('TEE = %1.2f (%1.2f;%1.2f)',TEE,lB95,uB95),strcat('TEE\%',sprintf(' = %1.2f (%1.2f;%1.2f)',TEE100,lB95/mean(criterion)*100,uB95/mean(criterion)*100)), sprintf('r = %1.3f', pearsonR(2)), strcat("$r^2$",sprintf(' = %1.3f',r_squared)),sprintf('y = %1.2fx%s%1.2f',coeff(2),signe,abs(coeff(1)))};
    text(0.05,0.75,str,'Units','normalized','Interpreter','latex','FontSize',9,'Color',[.2 .2 .2])
    %text(0.05,0.95,str(end),'Units','normalized','Interpreter','latex','FontSize',9,'Color',[.2 .2 .2])
    hold off
    xlabel('Criterion','Interpreter','latex')
    ylabel('Practical','Interpreter','latex')
    
    structStat.TypicalErrorEstimate = [TEE lB95 uB95];      % TEE lower upper (IC95%)
    structStat.TEE100 = [TEE lB95 uB95]./mean(criterion).*100;
    structStat.R2 = r_squared;
    structStat.Bias = diff(mean([criterion essaiB]));
    structStat.Bias100 = diff(mean([criterion essaiB]))/mean(criterion)*100;
    
    structStat.Pente = sprintf('y = %1.2fx+%1.2f',coeff(2),coeff(1));
    structStat.pearsonR = pearsonR(2);
    structStat.coeffVar.CV = CV;
    structStat.coeffVar.CI = CI;
elseif strcmpi(cond,'repro')
    
    [n, k] = size([criterion essaiB]);
    SStotal = var([criterion essaiB]) *(n*k - 1);
    MSR = var(mean([criterion essaiB], 2)) * k;
    MSC = var(mean([criterion essaiB], 1)) * n;
    MSE = (SStotal - MSR *(n - 1) - MSC * (k -1))/ ((n - 1) * (k - 1));     % McGraw and Wong (1996): Two-way mixed effects, absolute agreement, single rater/measurement ICC
    
    
    [iccData, lbData, ubDaat] = ICC_repro(MSR, MSE, MSC, 0.05, n, k);       % Koo and Li (2016) suggests 2way and absolute agreement for test retest studies
    
    TEM = std(diff([criterion essaiB],1,2))/sqrt(2);                           % Hopkins 2009: Typical Error of Measurement
    TEM100 = TEM/mean(criterion)*100;                                          % TEM as coefficient of variation (%)
    
    lB95 = sqrt((nbSuj-1)*TEM^2/(chi2inv(1-(1-0.95)/2,nbSuj-1)));
    uB95 = sqrt((nbSuj-1)*TEM^2/(chi2inv((1-0.95)/2,nbSuj-1)));
    
    
    %     SDo = std(essaiA);
    %     SDp = SDo*sqrt(iccData);
    SDp = std(criterion);
    SWC = SDp*0.2;                                                          % Hopkins 2015: dans sa fiche excel
    
    sensi = TEM>SWC;
    switch sensi
        case 1
            sensibility = ' (poor)';
        case 0
            sensibility = ' (good)';
    end
    
    
    str = {sprintf('n = %d',nbSuj), sprintf('TEM = %1.2f (%1.2f;%1.2f)', TEM,lB95,uB95),strcat('TEM\%',sprintf(' = %1.2f (%1.2f;%1.2f)',TEM100,lB95/mean(criterion)*100,uB95/mean(criterion)*100)),sprintf('$ICC_{2,1} = %1.3f$ (%1.2f ; %1.2f)',iccData,lbData,ubDaat), sprintf('r = %1.3f', pearsonR(2)), strcat(sprintf('SWC = %1.2f',SWC),sensibility),sprintf('y = %1.2fx+%1.2f',coeff(2),coeff(1))};
    text(0.05,0.75,str,'Units','normalized','Interpreter','latex','FontSize',9,'Color',[.2 .2 .2])
    hold off
    xlabel('Test','Interpreter','latex')
    ylabel('Retest','Interpreter','latex')
    
    structStat.ICC = iccData;
    structStat.ICC_IC95 = [lbData ubDaat];
    structStat.R2 = r_squared;
    structStat.Bias = diff(mean([criterion essaiB]));
    structStat.Pente = sprintf('y = %1.2fx+%1.2f',coeff(2),coeff(1));
    structStat.pearsonR = pearsonR(2);
    structStat.TEM = [TEM lB95 uB95];
    structStat.TEM100 = [TEM lB95 uB95]./mean(criterion)*100;
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


%%