function output = applyAuroraLevelAdjustment(input)

output = input/5/1.1;

if size(output,1)>10
    output = output';
end