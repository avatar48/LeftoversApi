json.array! @result do |single|
    json.stock single["stock"]
    json.code single["code"]
    json.name single["name"]
    json.unit single["unit"]
    json.amount single["amount"]
end
