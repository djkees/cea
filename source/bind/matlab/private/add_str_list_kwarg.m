function kwargs = add_str_list_kwarg(kwargs, name, value)
%ADD_STR_LIST_KWARG Append NAME/VALUE to KWARGS as a py.list if VALUE was supplied.
if isempty(value)
    return
end
kwargs = [kwargs, {name, matlab2pylist(value)}];
end
