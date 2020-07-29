function [average] = getaverage(Celltype,Times)
A = 0;
for j = 1:Times
   A = Celltype{j} + A;
end
average = A/Times;
end

