clf; close all; clearvars; clc

filepath = '/Users/ashish/OneDrive - Indian Institute of Science/MAC/Documents/MATLAB/Trade_Model_with_correct_Agri_n_Dom_PUB_Full/Considering_150LPCD_As_Choke_for_Dom_PUB_n_Corrected_Agri_PUB/';
% where our file is
filename = 'Iteration_2000_Corrected_Agri_PUB_n_Dom_150_Pub.xlsx';
% which file have the data
% Information about water allocation to various districts from all the
% major reservoir
%first step is to read the file contains data related to allocation from
%major reservoir 
ResDistAlloc = xlsread([filepath filename],2);%reading the excel file, that too the 14th sheet number where allocation matrix is given
ResDistAlloc = ResDistAlloc(1:6,1:13); %variable is define and asked to read the 1 to 13 rows (agents) and 1 to 6 columns (Reservoirs) of that sheet (13*6)
ResDistAlloc = ResDistAlloc;  %again the same variable is defined as a transpose of previous matrix now %Rows are Reservoirs and Column are Districts+Sectors(i.e agents) (6x13)
ResDistAllocOrg = ResDistAlloc; %creating a new variable for Reservoir district allocation (i.e quantity of water being transfered from one reservoir to one particular sector of that district
ind = isnan(ResDistAllocOrg);% to find the nan in the matrix, (ind) indicies will check all the element
ResDistAllocOrg(ind) = 0; % to replace all the nan with zero in allocation matrix
rowsum = sum(fix(ResDistAllocOrg), 2); % sum of the rows (i.e reservoir allocation needs to be constant throught out) 
ResDistAllocOrg = ResDistAlloc;
%2nd step is to read the data related to per unit benefits (PUB) for agricultutre and domestic
%sector

pub_agri_dom = xlsread([filepath filename],1,'B2:DTP14');%it has 14 rows and 3240 columns
%pub_agri_dom = xlsread([filepath filename],1,'LJ2:CDZ14');
zero_ind = find(pub_agri_dom(1,:) == 1000); %column number from which we will move left and right for PUB (trade)


global findBestPathOthResOnce;
findBestPathOthResOnce = 0;
% ResDistAlloc = ResDistAllocFinal{1,420};
SurplusforSellerDist =zeros(13,1);
SellerDistOrignalPUB =zeros(13,1);
ProfitDist = zeros(13, 1); %return a matrix of 13 rows and 1 column with all entries at zero
for iter = 1:zero_ind-1
   % iter = 1:zero_ind-1 %Loop for one iteration of 6 district trades
%     if iter>=470
%         display('Hi');
%     end
    profit_sum(iter) = 0; trade_count = 0;
    %Finding and sorting of willing seller in the market
    sell_pub = pub_agri_dom(:,zero_ind-iter);
    [sell_pub, sell_ind] = sort(sell_pub); %Sort 13 sell PUB in ascending order 
    % and return the indices of those elements as befor the sorting 
    ind = isnan(sell_pub);
    sell_pub = sell_pub(~ind); sell_ind = sell_ind(~ind);
    IndToBeRemoved = [];%vector 
    % In this step we are checking all the agents and their allocation
    % Reservoir from which that particular district or sector is not
    % getting any water needs to be removed. 
    for i = 1:length(sell_ind) % to be repeated till the the lenghth of sell_ind
        tmp = ResDistAlloc(:,sell_ind(i));%all rows and columns i (go to that particular dist column)
        % tmp will have allocation value matrix 
        ind = isnan(tmp);% put matrix of 1 n 0's 
        tmp = tmp(~ind);% it will remove those elemets whose logical value is true
        ind = find(tmp>=1);% return the indices of all the elements greater than equal to 1
       % to check logical if any district is such that they are not getting water from any reservoir
        if isempty(ind)
            IndToBeRemoved = [IndToBeRemoved i];% will remove that particular district for further trading
        end
    end
    sell_pub(IndToBeRemoved) = [];
    sell_ind(IndToBeRemoved) = [];
    % finding and sorting of willing buyers in the market
    buy_pub = pub_agri_dom(:,zero_ind+iter); % which colum values of PUB sheet to be taken 
    [buy_pub, buy_ind] = sort(buy_pub,'descend'); %Sort 13 buy PUB in descending order
    % it will give the value and indices of Buyers PUB in descending order
    ind = isnan(buy_pub);% if any nan value is present
   % after discarding nan value all other are used
    buy_pub = buy_pub(~ind); %give the value of PUB for all the buyers 
     % after discarding nan value all other are used
    buy_ind = buy_ind(~ind);% give the indices of all the buyers
    
   %%Mapping
   %Next step is to do one to one mapping of all the willing sellers and
   %buyers
    %sell_ind maps to buy_ind 1 to 1
    if ~isempty(sell_ind)% it means if there is any seller to sell water in the market if it is true then 
       % It will check for number of possible trades, without puting any
       % constraint on the possibility of trade
        for trade = 1:min(length(buy_ind),length(sell_ind)) %Loop for 1 trade between mapped seller and buyer 
            [iter trade]% give the indication of which iteration and in that iteration which trade number
            TradeVector = [];
            SellDist = sell_ind(trade); %Local Numbering (1 to 6 (Agri), 7 to 13 (Dom))
            % give the indicies of the sell district in that trade
            BuyDist = buy_ind(trade); %Local Numbering (1 to 6 (Agri), 7 to 13 (Dom))
           % give the indicies of the buy district in that trade
            if sell_pub(trade) <= buy_pub(trade)
                [path, ResDistAlloc, ResDistMap] = pathfinder(ResDistAlloc,SellDist,BuyDist,1);
                if isempty(path)
                    continue;
                end
                %
                profit_sum(iter) = profit_sum(iter) + buy_pub(trade);
                %profit_sum(iter) = profit_sum(iter) + buy_pub(trade) - sell_pub(trade);
                trade_count = trade_count + 1;
                %[SellDistTab BuyDistTab SellRes BuyRes DistMed Tradeqty]
                Tradefinal{trade,iter} = path;
                ResDistAllocFinal{trade,iter} = ResDistAlloc;
                tmp = ResDistAlloc;
                ind = isnan(tmp);
                tmp(ind) = 0;
                rowsumnew = sum(fix(tmp),2);
                if sum(rowsumnew == rowsum) ~= 6
                    error('Reservoir sum mismatch');
                end
            end
        end
    end
    if trade_count ~= 0
        %TODO: Check variable name, result to be displayed
        profit_avg(iter) = profit_sum(iter)/trade_count;
        ProfitDist(sell_ind(1:trade_count),iter) = profit_avg(iter);
        ProfitDist(buy_ind(1:trade_count),iter) = buy_pub(1:trade_count);
        SellerDistOrignalPUB(sell_ind(1:trade_count),iter) = sell_pub(1:trade_count);
        SellerDistOrignalPUB(buy_ind(1:trade_count),iter) = buy_pub(1:trade_count);
    %to calculate the surplus Directly
        SurplusforSellerDist(sell_ind(1:trade_count),iter) = (profit_avg(iter) - sell_pub(1:trade_count));
        SurplusforSellerDist(buy_ind(1:trade_count),iter) =(buy_pub(1:trade_count) - buy_pub(1:trade_count));
    end
   % plot(trade, trade_count, 'xr')
 
 

end
 %to write the excel sheet using write matrix
  warning off;
  Excel_ResDistAllocFinal = cell2mat(ResDistAllocFinal(1,1));
  filename = 'Allocation_Corrected_Agri_Dom_150_PUB.xlsx';
  Excel_Heading_Column=(1:13);
   Excel_Heading_Row={'R1'; 'R2'; 'R3'; 'R4'; 'R5';'R6'};
   writematrix(Excel_Heading_Column, filename, 'Sheet',1, 'Range','B1');
   writecell(Excel_Heading_Row, filename, 'Sheet', 1, 'Range','A2');
  writematrix(Excel_ResDistAllocFinal,filename,'Sheet',1,'Range','B2');
  
  Excel_ResDistAllocFinal = cell2mat(ResDistAllocFinal(1,590));
  filename = 'Allocation_Corrected_Agri_Dom_150_PUB.xlsx';
   Excel_Heading_Column=(1:13);
   Excel_Heading_Row={'R1'; 'R2'; 'R3'; 'R4'; 'R5';'R6'};
   writematrix(Excel_Heading_Column, filename, 'Sheet', 2, 'Range','B1');
   writecell(Excel_Heading_Row, filename, 'Sheet', 2, 'Range','A2');
  writematrix(Excel_ResDistAllocFinal,filename,'Sheet',2, 'Range','B2');
  
  Excel_Tradefinal=cell2mat(Tradefinal(1,1));
  Excel_Heading_Column={'SellDist', 'DistMed(ind)', 'BuyDist', 'SellDistRes(i)', 'BuyDistRes(j)','tmp'};
  writecell(Excel_Heading_Column, 'Trade_final_with_corrected_Agri_Dom_150_PUB.xlsx', 'Sheet', 1, 'Range','B1');
  writematrix(Excel_Tradefinal,'Trade_final_with_corrected_Agri_Dom_150_PUB.xlsx', 'sheet',1,'Range','B2');
  Excel_Tradefinal_1=cell2mat(Tradefinal(1,590));
  writecell(Excel_Heading_Column, 'Trade_final_with_corrected_Agri_Dom_150_PUB.xlsx', 'Sheet', 2, 'Range','B1');
  writematrix(Excel_Tradefinal_1,'Trade_final_with_corrected_Agri_Dom_150_PUB.xlsx','sheet',2,'Range','B2');
 
% % for col=1%:size(Tradefinal,2)
% %      col
% %      Excel_Tradefinal = cell2mat(Tradefinal(:,col));
% %      filename = 'Trade_final.xlsx';
% %      writematrix(Excel_Tradefinal,filename,'Sheet',col, 'Range','B2');
% % end
%   
% 
% %  for col=1:size(ResDistAllocFinal,2)
% %     col
% %     Excel_ResDistAllocFinal = cell2mat(ResDistAllocFinal(:,col));
% %     filename = 'Allocation.xlsx';
% %     writematrix(Excel_ResDistAllocFinal,filename,'Sheet',col, 'Range','B2');
% %  end
%  
%  
%  %Excel_ResDistAllocFinal = cell2mat(ResDistAllocFinal);
%  %filename = 'Allocation.xlsx';
%  %writematrix(Excel_ResDistAllocFinal,filename,'Sheet',1);
% %writecell(ResDistAllocFinal, 'Allocation_exp1.xlsx');
% 
  writematrix(profit_sum, 'profit_sum_with_corrected_Agri_Dom_150_PUB.xlsx');
  writematrix(ProfitDist, 'Profit_Dist_with_corrected_Agri_Dom_150_PUB.xlsx');
  y=~cellfun(@isempty,Tradefinal);
  x=length(find(~cellfun(@isempty,Tradefinal)));
  writematrix(y,'Trade_possible_in_one_Iter_with_corrected_Agri_Dom_150_PUB.xlsx');
  writematrix(SellerDistOrignalPUB, 'Seller_Dist_with_corrected_Agri_Dom_150_PUB.xlsx');
%to calculate the surplus directly
   writematrix(SurplusforSellerDist, 'Surplus_Dist_with_corrected_Agri_Dom_150_PUB.xlsx');
function [path, ResDistAlloc, ResDistMap] = pathfinder(ResDistAlloc,SellDist,BuyDist,updateResDistAlloc)
path = [];
global findBestPathOthResOnce
ResDistMap = createMap(ResDistAlloc,SellDist);
ResLink = findResLink(ResDistMap);

%Reservoir supplying water to seller district
SellDistRes = findDistRes(ResDistMap,SellDist);
%Reservoir supplying water to buyer district
BuyDistRes = findDistRes(ResDistMap,BuyDist);
%Check if same reservoir supply to both seller and buyer
%district
ind = ismember(SellDistRes,BuyDistRes);
if isempty(SellDistRes(ind))
    %Find path through common distrcit if there's no common reservoir supplying to seller and buyer
    counter = 0;
    for i = 1:length(SellDistRes)
        tmp1 = ResDistAlloc(SellDistRes(i),SellDist);
        for j = 1:length(BuyDistRes)
            DistMed = ResLink{SellDistRes(i),BuyDistRes(j)}; %Common districts between seller and buyer reservoirs
            if ~isempty(DistMed)
                tradeqty = [];
                for k = 1:length(DistMed)
                    tmp2 = ResDistAlloc(BuyDistRes(j),DistMed(k));
                    tradeqty = [tradeqty min(tmp1,tmp2)];
                end
                counter = counter+1;
                [tmp,ind] = max(tradeqty);
                %[SellRes BuyRes DistCommTab Quantity]
                %TradeVector(counter,:) = [SellDistRes(i) BuyDistRes(j) DistMedTab(ind) tmp];
                TradeVector(counter,:) = [SellDist DistMed(ind) BuyDist SellDistRes(i) BuyDistRes(j) tmp];
            end
        end
    end
    if counter ~= 0
        [tmp,ind] = max(TradeVector(:,6));
        path = TradeVector(ind,:);
        if updateResDistAlloc
            ResDistAlloc(path(4), path(1)) = ResDistAlloc(path(4), path(1)) - 1;
            ResDistAlloc(path(4), path(2)) = ResDistAlloc(path(4), path(2)) + 1;
            ResDistAlloc(path(5), path(2)) = ResDistAlloc(path(5), path(2)) - 1;
            ResDistAlloc(path(5), path(3)) = ResDistAlloc(path(5), path(3)) + 1;
        end
    else
        if findBestPathOthResOnce == 0
            findBestPathOthResOnce = 1;
            [BestPath, SellDistResOutput] = findBestPathOthRes(ResDistAlloc, ResDistMap, SellDistRes, SellDist, BuyDist);
            if isempty(BestPath)
                return
            end
            [tmp,ind] = max(BestPath(:,6));
            path = BestPath(ind,:);
            tmp1 = ResDistAlloc(SellDistRes(ind),SellDist);
            tmp = min(path(6), tmp1);
            %TODO: Check path fmt
            path = [SellDist path(1:3) SellDistRes(ind) path(4:5) tmp];
            ResDistAlloc(path(5), path(1)) = ResDistAlloc(path(5), path(1)) - 1;
            ResDistAlloc(path(5), path(2)) = ResDistAlloc(path(5), path(2)) + 1;
            ResDistAlloc(path(6), path(2)) = ResDistAlloc(path(6), path(2)) - 1;
            ResDistAlloc(path(6), path(3)) = ResDistAlloc(path(6), path(3)) + 1;
            ResDistAlloc(path(7), path(3)) = ResDistAlloc(path(7), path(3)) - 1;
            ResDistAlloc(path(7), path(4)) = ResDistAlloc(path(7), path(4)) + 1;
            findBestPathOthResOnce = 0;
        end
    end
else
    if SellDist == BuyDist
        return
    end
    ResComm = SellDistRes(ind);
    tradeqty = ResDistAlloc(ResComm,SellDist);
    [tmp,ind] = max(tradeqty);
    path = [SellDist BuyDist ResComm(ind) tmp];
    if updateResDistAlloc
        ResDistAlloc(path(3), path(1)) = ResDistAlloc(path(3), path(1)) - 1;
        ResDistAlloc(path(3), path(2)) = ResDistAlloc(path(3), path(2)) + 1;
    end
end

end
%square [] are for output argument in functions and () are for input
%arguments
function [BestPath, SellDistResOutput] = findBestPathOthRes(ResDistAlloc, ResDistMap, SellDistRes, SellDist, BuyDist)
SellDistResOutput = SellDistRes;
ResIndToBeRemoved = [];
BestPath = [];
tmpResDistAlloc = ResDistAlloc;
tmpResDistAlloc(:,SellDist) = 0;

for res = 1:length(SellDistRes)
    TradeVector = []; DistIndToBeRemoved = [];
    SellDistResOthDist = findResDist(ResDistMap,SellDistRes(res));
    % find all the district in seller reservoirs (including seller district itself
    ind = find(SellDistResOthDist == SellDist);
    SellDistResOthDist(ind) = [];
    % to remove the seller district itself to avoid self trading
    for dist = 1:length(SellDistResOthDist)
        tmpSellDistResAlloc = ResDistAlloc(:,SellDistResOthDist(dist));
        ind = isnan(tmpSellDistResAlloc);
        tmpSellDistResAlloc(ind) = [];% to avoid nan being counte as >1 
        ind = find(tmpSellDistResAlloc >= 1);
        if isempty(ind)
            DistIndToBeRemoved = [DistIndToBeRemoved dist];
            continue
        end
        [path, ResDistAllocNew, ResDistMap] = pathfinder(tmpResDistAlloc,SellDistResOthDist(dist),BuyDist,0);
        % without updating the allocation matrix as our focus is to check if any path is possible or not with dummy Med1 
        if isempty(path)
            DistIndToBeRemoved = [DistIndToBeRemoved dist];
            continue
        end
        if ResDistAllocNew ~= tmpResDistAlloc
            error('Error: ResDistAlloc got updated');
        end
        TradeVector(dist,:) = path;
    end
    SellDistResOthDist(DistIndToBeRemoved) = [];
    if isempty(TradeVector)
        ResIndToBeRemoved = [ResIndToBeRemoved res]; % IF no med1 possible, remove the respective reservoir
        continue
    else
        ind = find(DistIndToBeRemoved <= size(TradeVector,1));
        DistIndToBeRemoved = DistIndToBeRemoved(ind);
        TradeVector(DistIndToBeRemoved,:) = [];
    end
    [tmp,ind] = max(TradeVector(:,6));
    % to find best mediator 1 among all the possible mediator1 for the respective Res(dist in this case)
    % to find the ind of max quantity as it will give us the best path
    BestPath(res,:) = TradeVector(ind,:);
end
SellDistResOutput(ResIndToBeRemoved) = [];
if ~isempty(BestPath)
    ind = find(ResIndToBeRemoved <= size(BestPath,1));
    ResIndToBeRemoved = ResIndToBeRemoved(ind);
    BestPath(ResIndToBeRemoved,:) = [];
end

end

% this function is to creat a 1, 0 map for 13 agents from 6 reservoir,
% first 6 columns are for agri agents and afte that next 7 are for domestic
function ResDistMap = createMap(ResDistAlloc,SellDist)
ResDistMap = ResDistAlloc;
ind = find(ResDistAlloc>=1);
ResDistMap(ind) = 1;  
ResDistMap(~ind) = 0;

%Mediator with value less than 1 is not possible as a seller, but as a buyer is possible
SellRes = findDistRes(ResDistMap,SellDist);
tmp = ResDistMap(SellRes,:);
ind = find(ResDistAlloc(SellRes,:) > 0); %Not equal to zero, not to consider main seller as mediator while searching path for dummy seller, corresponding value will be forced to 0
tmp(ind) = 1;
ResDistMap(SellRes,:) = tmp;
end

function ResLink = findResLink(ResDistMap)
%Finding common districts between two reservoir (6x6)
for i = 1:5
    for j = i+1:6
        tmp1 = find(ResDistMap(i,:) == 1); %Find districts under Reservoir 1
        tmp2 = find(ResDistMap(j,:) == 1); %Find districts under Reservoir 2
        ind = ismember(tmp1,tmp2); %Find common district between two res
        ResLink{i,j} = tmp1(ind);
        ResLink{j,i} = ResLink{i,j}; %ResLink is a 6x6 cell
    end
end
end

function Res = findDistRes(ResDistMap,Dist)
[r,c] = find(ResDistMap(:,Dist) == 1); %Find reservoirs which supply water to particular district
Res = r;
end

function Dist = findResDist(ResDistMap,Res)
[r,c] = find(ResDistMap(Res,:) == 1);
Dist = c;
end