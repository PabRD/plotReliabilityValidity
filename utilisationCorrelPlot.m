%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                         %
%                          NAME: Validity/Reliability Studies             %
%                          AUTHOR: PabDawan                               %
%                          DATE: April 2023                               %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Exemple utlisation correlPlot
clear
close all
clc

%% Create fake data
% col = cbrewer('div','RdYlGn',5);
col =[0.8431    0.0980    0.1098
    0.9922    0.6824    0.3804
    1.0000    1.0000    0.7490
    0.6510    0.8510    0.4157
    0.1020    0.5882    0.2549];

rng(10)
criterion = (10:1:100)';
biaisAleatoire = criterion + 3 * randn(size(criterion));
biaisSystematique = @(x) 1.1*x-0.1;
% biaisSystematique = @(x) 1*x+0;

test = biaisSystematique(biaisAleatoire);
%% Validity
% We have a criterion and a practical dataset, we want to know the agreement between the two methods
figure
correlPlot(criterion,test,'valid')


%% Reproductibilité
% We want to know if what we measure is reliable
retest = test;
figure
correlPlot(criterion,retest,'repro',col)        % I specify my colors
