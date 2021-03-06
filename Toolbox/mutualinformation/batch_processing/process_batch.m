function [mi,ix,jx] = process_batch(data,ix,jx)
%% This function is called by compute_MI_PP and compute_MI_batch

if isstruct(data)
    gem = data.gem;
    px = data.px;
    ex = data.ex;
else
    load(data,'gem','px','ex');
end
clear data;

half = isequal(ix,jx); % Not along diagonal
mi = zeros([length(ix) length(jx)]);

for i = 1:length(ix)
    if sum(gem(ix(i),:))==0
        continue;
    end
    for j = 1:length(jx)
        if (half && ix(i)<=jx(j)) || (sum(gem(jx(j),:))==0)
            continue;
        end
        % Compute joint distribution and MI
        pxy = histcounts2(gem(ix(i),:),gem(jx(j),:),ex(ix(i),:),ex(jx(j),:));
        pxy = pxy / sum(pxy(:));
        % Alternative if histcounts2 not available (gives different results)
        %pxy = hist3([gem(ix(i),:)' gem(jx(j),:)'],'Edges',{ex(ix(i),:),ex(jx(j),:)});
        %pxy = pxy(1:end-1,1:end-1) / sum(pxy(:));
        mi(i,j) = sum(nansum(pxy .* log(pxy ./ (px(ix(i),:)'*px(jx(j),:)))));
    end
end

if half
    mi = mi+mi';
end