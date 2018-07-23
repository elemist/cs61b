clear all;
xlRange = 'C5:I10';
% A = xlsread('PostData.xlsx','Sheet1',xlRange);% 11 12 13
A = xlsread('PostData.xlsx','Sheet2',xlRange);
for i = 1:3
    B(i,:) =A(2*i,:)./A(2*i-1,:);
end
B = B';
C = [ones(7,1) B];

% spider(C,'Spider plot',[], {'Generator speed error';'Power';'RMS pitch rate';'Blade flap';'Blade egde';'Tower s-s';'Tower f-a'},...
%     {'Baseline' '11 m/s' '12 m/s' '13 m/s'});

spider(C,'Spider plot',[], {'Generator speed error';'Power';'RMS pitch rate';'Blade flap';'Blade egde';'Tower s-s';'Tower f-a'},...
    {'Baseline' '16 m/s' '18 m/s' '20 m/s'});
