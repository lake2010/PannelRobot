.pragma library

var MAX16 = 65536;

var configRanges = {
    "m_rw_0_16_0_0":[-100, 100],
    "m_rw_0_16_0_1":[2, 200],
    "m_rw_0_16_0_2":["m_rw_0_16_0_0", "m_rw_0_16_0_1"],
    "m_rw_0_16_0_16":[0, MAX16],
    "s_rw_0_16_3_265":[0, 100]
};

var getConfigRange = function(config){
    var r = configRanges[config];
    if(r === undefined){
        return undefined;
    }
    var items = config.split("_");
    return {"min":r[0], "max":r[1], "decimal":parseInt(items[4])};
};

var fncDefaultValues = {
    "m_rw_0_16_0_0":10,
    "m_rw_0_16_0_1":20,
    "m_rw_0_16_0_2":30,
    "m_rw_0_16_0_16":40,
    "m_rw_0_16_1_22":10.5
};
