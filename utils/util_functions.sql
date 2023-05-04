/* 
util_functions.sql
Website: https://university.yugabyte.com
Author: Seth Luersen
Purpose: Utility user-defined functions
*/

-- parses hex to int
create or replace function fn_hex_to_int(hexval text) 
returns int as $BODY$
select
  (get_byte(x,0)::int<<(3*8)) |
  (get_byte(x,1)::int<<(2*8)) |
  (get_byte(x,2)::int<<(1*8)) |
  (get_byte(x,3)::int)
from (
  select decode(lpad($1, 8, '0'), 'hex') as x
) as a;
$BODY$
language sql strict immutable;

-- parses webui tablet partition string
create or replace function fn_convert_partition_hex_range(p_partition text) 
returns text 
language plpgsql
AS 
$BODY$
declare range_beg int;
declare range_end int;
declare result text;
begin
    range_beg = fn_hex_to_int(substring(p_partition,16,4));
    range_end = fn_hex_to_int(substring(p_partition,24,4));
    result = format('%s-%s',range_beg,range_end);
    return result;
end;
$BODY$;

-- parses webui tablet partition string
create or replace function fn_find_hash_code_in_partition_hex_range(p_hash_code int, p_partition text) 
returns text 
language plpgsql
AS 
$BODY$
declare range_beg int;
declare range_end int;
declare result text = '';
begin
    range_beg = fn_hex_to_int(substring(p_partition,16,4));
    range_end = fn_hex_to_int(substring(p_partition,24,4));
    if p_hash_code >= range_beg and p_hash_code <= range_end then
        result = format('%s-%s',range_beg,range_end);
    end if;
    return result;
end;
$BODY$;


-- random names

create or replace function fn_random_name(isFirstName int default 0, isLastName int default 0)
returns text 
language plpgsql
AS 
$BODY$
declare
    first_names text[] = ARRAY['Adam','Bill','Bob','Calvin','Donald','Dwight','Frank','Fred','George','Howard','James','John','Jacob','Jack','Martin','Matthew','Max','Michael','Bill','Paul','Peter','Phil','Roland','Ronald','Samuel','Steve','Theo','Warren','William','Karthik','Suda','Mikhail','Kannan','Rachel','Bron','Mark','Jared','Tamar','Alec','Alex','Abigail','Alice','Allison','Amanda','Anne','Barbara','Betty','Carol','Cleo','Donna','Jane','Jennifer','Julie','Martha','Mary','Melissa','Patty','Sarah','Simone','Susan','Luke','Seth','Jake','Niki','David','Aidan','Patrick','Jerry','Dyuti','Gary'];
    last_names text[] = ARRAY['Matthews','Smith','Jones','Davis','Jacobson','Williams','Donaldson','Maxwell','Peterson','Stevens','Fitzgerald','Kim','Muthukkaruppan','Pescadero','Muthukkaruppan','Cook','Bautin','Srinivasan','Kraus','Franklin','Washington','Jefferson','Adams','Jackson','Johnson','Lincoln','Grant','Fillmore','Harding','Taft','Keefe','DeYoung', 'Yang','Lee', 'Truman','Nixon','Ford','Carter','Reagan','Bush','Clinton','Hancock','Uno','Gonzales','Weber','Neilsen','Gupta','Rogers'];
    size int = 0;
    first_name text='';
    last_name text='';
begin
    if isFirstName <> 0 and isLastName = 0 then
        size = array_length(first_names, 1);
        first_name = (first_names)[floor(random()*size)+1];
        RETURN first_name;
    end if;

    if isFirstName = 0  and isLastName <> 0 then
        size = array_length(last_names, 1);
        last_name =  (last_names)[floor(random()*size)+1];
        RETURN last_name;
    end if;

    RETURN '';
end;
$BODY$;


create or replace function fn_random_int_from_array(id int default 1)
returns int
language plpgsql
AS 
$BODY$
declare
    int_array int[] = ARRAY[101,102,104,105]; 
    size int = 0;
    int_value int =0;
begin
    if mod(id,2) = 1 then
        size = array_length(int_array, 1);
        int_value = (int_array)[floor(random()*size)+1];
        return int_value;
    else
        return 103::int;
    end if;

end;
$BODY$;



create or replace function fn_random_chars() 
returns text
as
$BODY$
select format('%s%s',chr(97+CAST(random() * 25 AS INTEGER)),chr(97+CAST(random() * 25 AS INTEGER)));
$BODY$
language sql;

