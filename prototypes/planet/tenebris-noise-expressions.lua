

data:extend {{
    type = "noise-expression",
    name = "tenebris_starting_area",
    expression = "1000"
}}

data:extend {{
    type = "noise-function",
    name = "distance_from_0_0",
    expression = "sqrt(xx * xx + yy * yy)",
    parameters = {"xx", "yy"}
}}