function interpret_turk( turk_annotations,name )

for k = 1:length(name)
%get the names from the files.
names = turk_annotations.annotation;
this_sheet = strfind(names,name{k});
index = find(~cellfun('isempty',this_sheet));

value_string = turk_annotations.Answertag1;
clear x_val y_val human_labels i
for i = 1:length(index)
    this_i = index(i);
    slashind = strfind(names{this_i},'/');
    slashind = max(slashind)
    
    periodind = strfind(names{this_i},'.');
    periodind = max(periodind);
    
    underind = strfind(names{this_i},'_');
    
    this_name = names{this_i};
    
    this_value = value_string{this_i};
    
    x_val(this_i) = str2num(this_name(underind(end-1)+1:underind(end)-1));
    y_val(this_i) = str2num(this_name(underind(end)+1:periodind-1));

    file_name = this_name(slashind+1:underind(end-1)-1);
    
    %human_labels{x_val(i),y_val(i)} = str2num(this_value(2:end-1)) 
     human_labels{x_val(this_i),y_val(this_i)} = this_value(2:end-1); 
end
save([file_name '_human_labels.mat'],'human_labels')


end



end

