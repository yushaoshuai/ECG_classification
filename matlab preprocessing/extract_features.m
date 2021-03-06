function [sameLenST sameLenHeightST ftOriginalCell ftSameLenCell ftSameLenHeightCell] = extract_features...
    (twelveECG, indexQ, indexR, indexS, indexT, orderOfFit, method)
% Purpose:
% get the normalized  ST segments, [1 100 0 1], and fit these segments, get
% the ftCoeffients of function fitting as features for MI recognition
% 
% Inputs:
% 'twelveECG' 12x10000 mat
% 
% 'indexR' is the location of R 
% 
% 'indexS' is the location of S 
% 
% 'indexT' is the location of T 
% 
% Outputs:
% 'sameLenHeightST' the normalized  ST segments, whose dimension is t x 1200, 
% where t is the number of ST-segments of each lead.
% 
% 'featureCell' is ftCoefficients of function fitting, which are used as
% features, whose dimension is 12x1, each cell-element is a mat of [tx9],
% where t is the number of ST-segments, 9 is the length of each feature
assert(strcmp(method, 'fit')||strcmp(method, 'dct'));
nbrBeats = length(indexS);
lenQS = (indexS - indexQ +1)';
lenST = (indexT - indexS +1)';
lenRR = (diff(indexR))';
lenSTnorm = 200;
nbrDctCoeff = 15;% number of dct coeffients used as features

heightST = zeros(nbrBeats, 1);
heightQS = zeros(nbrBeats, 1);

coeffCell = cell(3, 1); %get the  fit or dct coeffients as features
sameLenSTcell = cell(nbrBeats, 12);
sameLenHeightSTcell = cell(nbrBeats, 12);
ftOriginalCell = cell(12, 1);
ftSameLenCell = cell(12, 1);
ftSameLenHeightCell = cell(12, 1);

for i = 1:12
    srcData = twelveECG(i, :);
    for t = 1:nbrBeats
        
        originalST = srcData(indexS(t):indexT(t));
        originalST = originalST - originalST(1);
        
        heightST(t) = srcData(indexT(t)) - srcData(indexS(t));
        heightQS(t) = srcData(indexS(t)) - srcData(indexQ(t));
        
        sameLenST = resample(originalST, lenSTnorm, lenST(t));
       
        minVal = min(originalST);
        maxVal = max(originalST);
        isZero = (maxVal-minVal==0);        
        sameLenHeightST = (originalST-minVal)/(maxVal-minVal+isZero);
        sameLenHeightST = resample(sameLenHeightST, lenSTnorm, lenST(t));
        
        
        sameLenSTcell{t, i} = sameLenST;
        sameLenHeightSTcell{t, i} = sameLenHeightST;
        
        if strcmp(method, 'fit')
        x = 1:length(originalST);        
        p = polyfit(x, originalST, orderOfFit);
        coeffCell{1}(t,:) = p;
        
        x = 1:lenSTnorm;
        p = polyfit(x, sameLenST, orderOfFit);
        coeffCell{2}(t,:) = p;   
        
        x = 1:lenSTnorm;
        p = polyfit(x, sameLenHeightST, orderOfFit);
        coeffCell{3}(t,:) = p;      
        
        elseif strcmp(method, 'dct')  
        dctData = dct(originalST);        
        coeffCell{1}(t,:) = dctData(1:nbrDctCoeff);
        
        dctData = dct(sameLenST);        
        coeffCell{2}(t,:) = dctData(1:nbrDctCoeff);
        
        dctData = dct(sameLenHeightST);        
        coeffCell{3}(t,:) = dctData(1:nbrDctCoeff);             
        end
            
    end
    ftOriginalCell{i} = coeffCell{1};
    ftSameLenCell{i} = coeffCell{2};
    ftSameLenHeightCell{i} = coeffCell{3};
%     ftOriginalCell{i} = cat(2, lenRR, lenQS, lenST, heightQS, heightST,coeffCell{1});
%     ftSameLenCell{i} = cat(2, lenRR, lenQS, lenST, heightQS, heightST, coeffCell{2});
%     ftSameLenHeightCell{i} = cat(2, lenRR, lenQS, lenST, heightQS, heightST, coeffCell{3});
end

 ftOriginalCell{i+1} = [lenST./lenRR,heightST./lenST];
 ftSameLenCell{i+1} = [lenST./lenRR,heightST./lenST];
 ftSameLenHeightCell{i+1} = [lenST./lenRR,heightST./lenST];

sameLenST = cell2mat(sameLenSTcell);
sameLenHeightST = cell2mat(sameLenHeightSTcell);