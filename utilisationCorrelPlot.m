% Exemple utlisation correlPlot
clear
close all
clc

% Create fake data
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
test1 = criterion;
test2 = test;
figure
correlPlot(test1,test2,'repro')
