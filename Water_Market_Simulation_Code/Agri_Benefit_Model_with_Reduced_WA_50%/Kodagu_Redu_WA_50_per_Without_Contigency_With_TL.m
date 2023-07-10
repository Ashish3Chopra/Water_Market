clear variables; clc; clf; close all
format long

% Mysore
% QP QR QM QS
filepath = '/Users/ashish/OneDrive - Indian Institute of Science/MAC/Documents/MATLAB/Agri_Benefit_Model/Agri_Benefit_Model_with_Reduced_WA_50%/';
filename = 'Kodagu_Agri_PUB_with_Redu_WA_50per.xlsx';
delete([filepath filename])
% Kodagu trial without contigency plan and area with tolerance limit and
% with losses i.e area is update considering all these variable
% not we are considering talkul level and water availability changed due to
% this hence re do the PUB calucltion. 
%f = [-0.7261 -3.8273 -6.5016 0];
f = [-8.076022534 -23.57346946 -27.64204494 0];
Aeq = []; beq = []; lb = [0 0 0 0]; ub = [];
A = [1 1 1 0
     1 2.777 2.0833 0
     -1 164.2777963*2.777*0.95 0 0
     1 -164.2777963*2.777*1.05 0 0
     -1 0 9.938431705*2.083*0.95 0 
      1 0 -9.938431705*2.083*1.05 0
      0 -1 0.060497717*.75*0.95 0 
      0 1 -0.060497717*.75*1.05 0 
      
     ];

%TWA = 21371513.21;
% Basic Status Quo Allocation
%TWA = 9587813.385;
TWA = 4793906.69;
WA = []; xsol = []; fvalue = [];
pstvlmt = 2000; ngtvlmt = 4;
for i = [0:pstvlmt -1:-1:-ngtvlmt]
    %[-9:2000]
    i
    WA = [WA TWA+1000000*i];
    b = [TWA+1000000*i 1364.685161*12500 0 0 0 0 0 0];
    [x, fval] = linprog(f,A,b,Aeq,beq,lb,ub);
    xsol = [xsol x];
    fvalue = [fvalue -fval];
     if i==0
        zeroind = length(fvalue);
        
     end
end

Qtotal = sum(xsol);
EW = WA - Qtotal;
EW_max = max(EW)
EW_min = min(EW)
Surplus(2:pstvlmt+1) = fvalue(2:pstvlmt+1)-fvalue(1:pstvlmt); %(i= 1 to 2000) - (i= 0 to 1999)
Surplus(1) = fvalue(1)-fvalue(1); %(i= 0) - (i= 0)
Surplus(pstvlmt+2) = fvalue(1) - fvalue(pstvlmt+2); %(i= 0) - (i= -1)
Surplus(pstvlmt+3:pstvlmt+ngtvlmt+1) = fvalue(pstvlmt+2:pstvlmt+ngtvlmt) - fvalue(pstvlmt+3:pstvlmt+ngtvlmt+1); %(i= -1 to -142) - (i= -2 to -143)
AreaP = xsol(1,:)/12500;
AreaR = xsol(2,:)/4500;
AreaM = xsol(3,:)/6000;
AreaS = xsol(4,:)/20000;
AreaTotal = AreaP+AreaR+AreaM+AreaS;
PerCentTAA = (AreaTotal/1364.685161)*100;
PUB = Surplus./(1000000);
PUB(zeroind) = 0;
Iteration = [0:pstvlmt -1:-1:-ngtvlmt];

excel_message = {'TWA'; ''; 'QP'; 'QR'; 'QM'; 'QS'; 'Qtotal'; 'EW'; '';...
    'Agri Bene'; ''; 'Surplus Bene'; ''; 'AP'; 'AR'; 'AM'; 'AS';...
    'Total Area'; '% of TAA'; ''; 'PUB'; ''; 'Iteration'};
excel_TWA = num2cell(WA);
excel_Q = num2cell(xsol);
excel_Qtotal = num2cell(Qtotal);
excel_Benefit = num2cell(fvalue);
excel_EW = num2cell(EW);
excel_Surplus = num2cell(Surplus);
excel_AreaP = num2cell(AreaP);
excel_AreaR = num2cell(AreaR);
excel_AreaM = num2cell(AreaM);
excel_AreaS = num2cell(AreaS);
excel_AreaTotal = num2cell(AreaTotal);
excel_PerCentTAA = num2cell(PerCentTAA);
excel_PUB = num2cell(PUB);
excel_Iteration = num2cell(Iteration);

writecell(excel_message, [filepath filename],'Range','A1:A21')
writecell(excel_TWA, [filepath filename],'Range','B1')
writecell(excel_Q, [filepath filename],'Range','B3')
writecell(excel_Qtotal, [filepath filename],'Range','B7')
writecell(excel_EW, [filepath filename],'Range','B8')
writecell(excel_Benefit, [filepath filename],'Range','B10')
writecell(excel_Surplus, [filepath filename],'Range','B12')
writecell(excel_AreaP, [filepath filename],'Range','B14')
writecell(excel_AreaR, [filepath filename],'Range','B15')
writecell(excel_AreaM, [filepath filename],'Range','B16')
writecell(excel_AreaS, [filepath filename],'Range','B17')
writecell(excel_AreaTotal, [filepath filename],'Range','B18')
writecell(excel_PerCentTAA, [filepath filename],'Range','B19')
writecell(excel_PUB, [filepath filename],'Range','B21')
writecell(excel_Iteration, [filepath filename],'Range','B23')

writematrix('Kodagu', [filepath 'PUB_ord_WA_50%_Red.xlsx'],'Range','A2')
writecell(excel_PUB, [filepath 'PUB_ord_WA_50%_Red.xlsx'],'Range','B2')
writematrix('Kodagu', [filepath 'Benefit_ord_WA_50%_Red.xlsx'],'Range','A2')
writecell(excel_Benefit, [filepath 'Benefit_ord_WA_50%_Red.xlsx'],'Range','B2')