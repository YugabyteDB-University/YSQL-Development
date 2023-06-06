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
    int_array int[] = ARRAY[8, 35, 37, 47, 50, 54, 55, 58, 67, 75, 84, 102, 111, 117, 118, 135, 137, 140, 144, 146, 148, 158, 161, 163, 168, 179, 188, 195, 209, 232, 262, 320, 350, 359, 365, 367, 371, 379, 385, 394, 396, 403, 422, 426, 436, 438, 444, 447, 462, 477, 496, 510, 548, 569, 576, 598, 620, 629, 632, 639, 641, 643, 651, 654, 658, 679, 710, 713, 718, 728, 733, 736, 741, 749, 760, 773, 776, 783, 790, 814, 816, 836, 839, 846, 849, 853, 871, 887, 895, 898, 907, 911, 918, 933, 940, 962, 966, 977, 987, 989, 1034, 1037, 1043, 1044, 1049, 1055, 1066, 1079, 1084, 1092, 1094, 1102, 1109, 1114, 1121, 1127, 1146, 1148, 1156, 1157, 1168, 1206, 1222, 1226, 1230, 1231, 1241, 1285, 1288, 1321, 1322, 1324, 1326, 1346, 1352, 1355, 1378, 1388, 1396, 1454, 1508, 1519, 1522, 1525, 1527, 1563, 1573, 1585, 1595, 1600, 1604, 1614, 1622, 1625, 1627, 1641, 1651, 1674, 1701, 1704, 1705, 1737, 1746, 1751, 1759, 1764, 1784, 1786, 1800, 1810, 1824, 1832, 1837, 1839, 1842, 1846, 1854, 1859, 1863, 1867, 1872, 1901, 1935, 1939, 1942, 1943, 1952, 1962, 1965, 1967, 1979, 2020, 2023, 2060, 2062, 2063, 2084, 2101, 2124, 2125, 2131, 2139, 2146, 2151, 2163, 2175, 2178, 2187, 2198, 2209, 2212, 2219, 2247, 2252, 2281, 2289, 2290, 2313, 2318, 2319, 2327, 2333, 2340, 2342, 2343, 2344, 2345, 2359, 2396, 2399, 2416, 2422, 2427, 2428, 2430, 2438, 2439, 2445, 2448, 2451, 2462, 2463, 2465, 2467, 2472, 2479, 2483, 2486, 2489, 2492, 2495, 2514, 2520, 2523, 2525, 2534, 2538, 2542, 2546, 2551, 2561, 2566, 2578, 2586, 2605, 2614, 2633, 2660, 2665, 2666, 2671, 2693, 2696, 2698, 2708, 2711, 2714, 2715, 2731, 2766, 2768, 2785, 2790, 2793, 2804, 2816, 2845, 2859, 2870, 2878, 2886, 2909, 2910, 2931, 2937, 2960, 2968, 2975, 2986, 3006, 3017, 3019, 3023, 3024, 3025, 3039, 3048, 3060, 3072, 3081, 3111, 3132, 3133, 3145, 3170, 3174, 3194, 3196, 3220, 3235, 3241, 3258, 3269, 3288, 3294, 3295, 3321, 3353, 3359, 3360, 3370, 3373, 3375, 3417, 3418, 3420, 3435, 3437, 3446, 3452, 3465, 3478, 3514, 3519, 3521, 3535, 3553, 3555, 3561, 3565, 3566, 3575, 3604, 3611, 3616, 3628, 3629, 3630, 3684, 3740, 3761, 3766, 3770, 3773, 3783, 3784, 3809, 3834, 3845, 3847, 3862, 3879, 3889, 3892, 3914, 3926, 3935, 3949, 3951, 3959, 3964, 3977, 3996, 4018, 4032, 4037, 4043, 4045, 4068, 4073, 4079, 4086, 4089, 4097, 4108, 4116, 4122, 4137, 4143, 4144, 4148, 4152, 4167, 4199, 4225, 4237, 4254, 4256, 4263, 4279, 4310, 4321, 4322, 4323, 4327, 4345, 4351, 4365, 4383, 4385, 4428, 4436, 4442, 4457, 4475, 4477, 4485, 4497, 4505, 4521, 4542, 4567, 4580, 4582, 4610, 4626, 4629, 4637, 4644, 4654, 4669, 4690, 4711, 4730, 4750, 4764, 4766, 4779, 4781, 4794, 4809, 4817, 4820, 4838, 4861, 4862, 4864, 4878, 4880, 4884, 4888, 4954, 4959, 4960, 4965, 4978, 4981, 4993, 5004, 5022, 5026, 5032, 5033, 5037, 5038, 5044, 5045, 5048, 5053, 5074, 5079, 5085, 5086, 5096, 5110, 5111, 5112, 5117, 5129, 5152, 5154, 5187, 5195, 5219, 5229, 5233, 5245, 5246, 5260, 5264, 5287, 5291, 5292, 5321, 5326, 5332, 5334, 5348, 5369, 5382, 5403, 5404, 5415, 5425, 5436, 5457, 5466, 5474, 5483, 5499, 5500, 5501, 5503, 5504, 5513, 5520, 5530, 5534, 5544, 5548, 5560, 5562, 5566, 5567, 5647, 5654, 5669, 5677, 5683, 5685, 5692, 5694, 5716, 5718, 5744, 5745, 5747, 5765, 5774, 5783, 5794, 5800, 5808, 5824, 5837, 5839, 5875, 5900, 5920, 5935, 5949, 5962, 5963, 5975, 5988, 5991, 5995, 5996, 6011, 6018, 6019, 6039, 6041, 6049, 6054, 6056, 6060, 6076, 6081, 6083, 6092, 6115, 6132, 6148, 6163, 6173, 6191, 6210, 6224, 6225, 6229, 6230, 6248, 6253, 6255, 6262, 6278, 6310, 6324, 6325, 6337, 6347, 6362, 6366, 6369, 6370, 6384, 6408, 6412, 6413, 6425, 6435, 6454, 6456, 6468, 6500, 6507, 6512, 6530, 6545, 6596, 6601, 6623, 6628, 6630, 6648, 6653, 6659, 6666, 6677, 6683, 6690, 6692, 6694, 6702, 6713, 6716, 6720, 6739, 6759, 6783, 6784, 6830, 6837, 6840, 6842, 6851, 6854, 6861, 6866, 6868, 6871, 6895, 6900, 6910, 6924, 6932, 6935, 6940, 6953, 6957, 6994, 6995, 7002, 7020, 7030, 7035, 7049, 7056, 7060, 7072, 7081, 7084, 7101, 7102, 7106, 7121, 7130, 7141, 7160, 7167, 7173, 7178, 7180, 7191, 7192, 7245, 7246, 7265, 7270, 7306, 7310, 7311, 7316, 7320, 7325, 7327, 7340, 7346, 7351, 7357, 7384, 7386, 7423, 7426, 7431, 7434, 7442, 7466, 7468, 7471, 7473, 7487, 7502, 7507, 7510, 7517, 7519, 7530, 7539, 7546, 7547, 7559, 7562, 7563, 7580, 7583, 7587, 7596, 7623, 7624, 7631, 7640, 7649, 7670, 7672, 7698, 7702, 7717, 7720, 7729, 7735, 7750, 7770, 7779, 7780, 7782, 7787, 7789, 7802, 7814, 7839, 7844, 7853, 7855, 7856, 7863, 7880, 7885, 7886, 7910, 7918, 7945, 7960, 7992, 8006, 8008, 8024, 8039, 8047, 8055, 8062, 8072, 8083, 8097, 8103, 8108, 8153, 8164, 8166, 8167, 8233, 8235, 8239, 8241, 8244, 8246, 8250, 8256, 8283, 8285, 8303, 8312, 8313, 8315, 8320, 8325, 8326, 8330, 8336, 8349, 8351, 8359, 8360, 8367, 8370, 8380, 8382, 8402, 8403, 8405, 8417, 8425, 8428, 8434, 8442, 8444, 8461, 8466, 8474, 8481, 8490, 8515, 8519, 8529, 8535, 8540, 8549, 8550, 8557, 8558, 8571, 8574, 8575, 8576, 8577, 8584, 8589, 8611, 8615, 8620, 8625, 8630, 8644, 8645, 8651, 8660, 8670, 8680, 8686, 8689, 8707, 8713, 8720, 8745, 8750, 8754, 8755, 8763, 8764, 8781, 8784, 8793, 8799, 8813, 8820, 8838, 8861, 8883, 8895, 8904, 8921, 8922, 8923, 8926, 8934, 8946, 8967, 8968, 8992, 8995, 9000, 9010, 9015, 9021, 9033, 9046, 9047, 9051, 9056, 9065, 9075, 9098, 9102, 9118, 9129, 9131, 9147, 9153, 9159, 9160, 9162, 9176, 9178, 9183, 9187, 9196, 9204, 9211, 9218, 9220, 9257, 9258, 9259, 9278, 9289, 9321, 9331, 9343, 9362, 9363, 9365, 9374, 9382, 9390, 9404, 9413, 9415, 9432, 9458, 9463, 9466, 9497, 9514, 9528, 9539, 9540, 9552, 9558, 9573, 9584, 9595, 9605, 9606, 9609, 9610, 9616, 9619, 9620, 9641, 9646, 9651, 9658, 9673, 9685, 9687, 9694, 9697, 9700, 9704, 9706, 9709, 9711, 9723, 9726, 9728, 9731, 9733, 9742, 9744, 9747, 9755, 9773, 9778, 9780, 9790, 9794, 9797, 9801, 9809, 9813, 9819, 9822, 9854, 9897, 9900, 9918, 9935, 9946, 9949, 9950, 9951, 9961, 9965, 9977, 9981, 9991, 9992, 9994, 9999]; 
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

-- select fn_uuid_into_timestamptz(uuid_generate_v1()), now());
create or replace function fn_uuid_into_timestamptz(uuid uuid) returns timestamptz as $$
declare
  bytes bytea; 
begin
  bytes := uuid_send(uuid);
  return to_timestamp(
             (
                 (
                   (get_byte(bytes, 0)::bigint << 24) |
                   (get_byte(bytes, 1)::bigint << 16) |
                   (get_byte(bytes, 2)::bigint <<  8) |
                   (get_byte(bytes, 3)::bigint <<  0)
                 ) + (
                   ((get_byte(bytes, 4)::bigint << 8 |
                   get_byte(bytes, 5)::bigint)) << 32
                 ) + (
                   (((get_byte(bytes, 6)::bigint & 15) << 8 | get_byte(bytes, 7)::bigint) & 4095) << 48
                 ) - 122192928000000000
             ) / 10000 / 1000::double precision
         );
end
$$ language plpgsql
immutable parallel safe
returns null on null input;