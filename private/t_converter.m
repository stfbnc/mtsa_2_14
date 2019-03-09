%%% author: Stefano Bianchi
%%% contact: stefano.bianchi@uniroma3.it
%%% last modified 2018/04/15
%%% convert time units
%%% INPUT PARAMETERS:
%%% - time_units : time units
%%% OUTPUT PARAMETERS:
%%% - units_converter : number to convert time units and to obtain periods in units of time units
%%% USAGE:
%%% units_converter = t_converter(time_units)

function units_converter = t_converter(time_units)

switch time_units
    case 'seconds'
        units_converter = 31536000;
    case 'minutes'
        units_converter = 525600;
    case 'hours'
        units_converter = 8760;
    case 'days'
        units_converter = 365;
    case 'weeks'
        units_converter = 52;
    case 'months'
        units_converter = 12;
end

end
