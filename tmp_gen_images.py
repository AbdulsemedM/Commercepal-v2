# Generates curated Unsplash URLs for every unique subcategory name.
# Photo IDs are well-known Unsplash assets (free license).

PHOTOS = {
    # Electronics
    "smartphones": "photo-1511707171634-5f897ff02aa9",
    "android phones": "photo-1511707171634-5f897ff02aa9",
    "phone cases": "photo-1601784551446-20c9e07cdbdb",
    "chargers": "photo-1591290619762-c588f7cb0f0a",
    "screen protectors": "photo-1601784551446-20c9e07cdbdb",
    "power banks": "photo-1609091839311-b54859ee4700",
    "laptops": "photo-1496181133206-80ce9b88a853",
    "gaming laptops": "photo-1603302576837-37561b2e2302",
    "laptop bags": "photo-1553062407-98eeb64c6a62",
    "laptop stands": "photo-1527864550417-7fd91fc51a46",
    "laptop chargers": "photo-1591290619762-c588f7cb0f0a",
    "headphones": "photo-1505740420928-5e560c06d30e",
    "bluetooth earbuds": "photo-1590658268037-6bf12165a8df",
    "speakers": "photo-1545454675-3531b543be5d",
    "microphones": "photo-1590602847861-f357a9332bbc",
    "smart watches": "photo-1523275335684-37898b6baf30",
    "smart watch bands": "photo-1579586337278-3befd40fd17a",
    "fitness trackers": "photo-1575311373937-040b8e1fd5b6",
    "tablets": "photo-1544244015-0df4b3ffc6b0",
    "android tablets": "photo-1544244015-0df4b3ffc6b0",
    "tablet cases": "photo-1544244015-0df4b3ffc6b0",
    "stylus pens": "photo-1587829741301-dc798b83add3",
    "tablet keyboards": "photo-1587829741301-dc798b83add3",
    "desktop pcs": "photo-1593640408182-31c70c8268f5",
    "monitors": "photo-1527443224154-c4a3942d3acf",
    "keyboards": "photo-1587829741301-dc798b83add3",
    "computer mice": "photo-1527864550417-7fd91fc51a46",
    "webcams": "photo-1587825140708-dfaf72ae4b04",
    "protective cases": "photo-1601784551446-20c9e07cdbdb",
    # Fashion
    "women's clothing": "photo-1483985988355-763728e1935b",
    "men's clothing": "photo-1490114538077-0a7f8cb49891",
    "dresses": "photo-1595777457583-95e059d581b8",
    "tops": "photo-1434389677669-e08b4cac3105",
    "men shirts": "photo-1596755094514-f87e34085b2c",
    "men jeans": "photo-1542272454315-7f6b1c595653",
    "men jackets": "photo-1551028719-00167b16eac5",
    "shoes": "photo-1542291026-7eec264c27ff",
    "women shoes": "photo-1543163521-1bf539c55dd2",
    "men shoes": "photo-1614252234055-2e0a1d0c1b1a",
    "sneakers": "photo-1542291026-7eec264c27ff",
    "sandals": "photo-1603487742131-4160ec999306",
    "boots": "photo-1608256246200-53e635b5b65f",
    "formal shoes": "photo-1614252369475-531eba835eb1",
    "bags": "photo-1548036328-c9fa89d128fa",
    "handbags": "photo-1584917865442-de89df76afd3",
    "accessories": "photo-1492707892479-7bc8d5a4ee93",
    "belts": "photo-1624222247344-550fb60583fd",
    "sunglasses": "photo-1511499767150-a48a237f0083",
    "hats": "photo-1521369909029-2afed882baee",
    "wallets": "photo-1627123424574-724758594e93",
    "abayas": "photo-1585487000160-6ebcfceb0d03",
    "hijabs": "photo-1594938298603-c8148c4dae35",
    "modest dresses": "photo-1595777457583-95e059d581b8",
    "prayer clothes": "photo-1585487000160-6ebcfceb0d03",
    # Beauty
    "makeup": "photo-1596462502278-27bfdc403348",
    "foundation": "photo-1596462502278-27bfdc403348",
    "lipstick": "photo-1586495777744-4413f21062fa",
    "mascara": "photo-1631214524020-7e18db9a8f92",
    "eyeshadow": "photo-1512496015851-a90fb38ba796",
    "skincare": "photo-1556228578-0d85b1a4d571",
    "moisturizer": "photo-1556228578-0d85b1a4d571",
    "face wash": "photo-1556228720-195a672e8a03",
    "serum": "photo-1620916568147-7af4bd3c8e5d",
    "sunscreen": "photo-1556228720-195a672e8a03",
    "perfume": "photo-1541643600914-78b084683601",
    "women's perfume": "photo-1541643600914-78b084683601",
    "men's cologne": "photo-1594035910387-fea47794261f",
    "body mist": "photo-1594035910387-fea47794261f",
    "gift sets": "photo-1549465220-1a8b9238cd48",
    "hair care": "photo-1522338140262-f46f5913618a",
    "lotion": "photo-1556228578-8c89e6adf883",
    "body lotion": "photo-1556228578-8c89e6adf883",
    "hand cream": "photo-1556228720-195a672e8a03",
    "face cream": "photo-1556228578-0d85b1a4d571",
    # Home
    "blenders": "photo-1570222094114-d054a817e56b",
    "irons": "photo-1582735689369-4fe89db7114c",
    "vacuum cleaners": "photo-1558317374-067fb5f30001",
    "air fryers": "photo-1585515320310-259814833e62",
    "rice cookers": "photo-1585515320310-259814833e62",
    "kitchen tools": "photo-1556910103-1c02745aae4d",
    "bedding": "photo-1522771739844-6a9f6d5f14af",
    "lighting": "photo-1513506003901-1e6a229e2d15",
    "storage": "photo-1595428774223-ef52624120d2",
    "sofas": "photo-1555041469-a586c61ea9bc",
    "tables": "photo-1533090481720-856c6e3c1fdc",
    "chairs": "photo-1506439773649-6e0eb8cfb237",
    "shelves": "photo-1595428774223-ef52624120d2",
    "home decor": "photo-1513519245088-0e12902e35a6",
    "furniture": "photo-1555041469-a586c61ea9bc",
    # Auto
    "car accessories": "photo-1492144534655-ae79c964c9d7",
    "car chargers": "photo-1591290619762-c588f7cb0f0a",
    "dash cams": "photo-1449965408869-eaa3f722e40d",
    "car covers": "photo-1492144534655-ae79c964c9d7",
    "phone holders": "photo-1511707171634-5f897ff02aa9",
    # Sports
    "sports shoes": "photo-1542291026-7eec264c27ff",
    "fitness equipment": "photo-1517836357463-d25dfeac3438",
    "yoga mats": "photo-1544367567-0f2fcb009e0b",
    "water bottles": "photo-1602143407151-7111542de6e8",
    "sportswear": "photo-1517836357463-d25dfeac3438",
    "dumbbells": "photo-1517836357463-d25dfeac3438",
    "resistance bands": "photo-1598289431512-b97b0917affc",
    # Watches / jewelry
    "men's watches": "photo-1524592094714-0f0654e20314",
    "women's watches": "photo-1522312346375-d1a52e170b0c",
    "watch straps": "photo-1523275335684-37898b6baf30",
    "analog watches": "photo-1524592094714-0f0654e20314",
    "digital watches": "photo-1523275335684-37898b6baf30",
    "luxury watches": "photo-1523170335258-f5ed11844a49",
    "fashion watches": "photo-1522312346375-d1a52e170b0c",
    "jewelry watches": "photo-1522312346375-d1a52e170b0c",
    "necklaces": "photo-1515562141207-7a88fb7ce338",
    "earrings": "photo-1535632066927-ab7c9ab60908",
    "bracelets": "photo-1611591437281-460bfbe1220a",
    "rings": "photo-1605100804763-247f67b3557e",
    # Kids / baby
    "baby clothes": "photo-1515488042361-ee00e0ddd4e4",
    "diapers": "photo-1515488042361-ee00e0ddd4e4",
    "baby toys": "photo-1515488042361-ee00e0ddd4e4",
    "feeding bottles": "photo-1515488042361-ee00e0ddd4e4",
    "kids clothes": "photo-1503919545889-aef636e10ad4",
    "toys": "photo-1558060370-d644479cb6f7",
    "school bags": "photo-1553062407-98eeb64c6a62",
    "kids shoes": "photo-1514989940723-188eb64127a0",
    "educational toys": "photo-1587654780291-39c9404d746b",
    "action figures": "photo-1558060370-d644479cb6f7",
    "board games": "photo-1632501641765-e568d28b0015",
    "soft toys": "photo-1530325553465-bfb0f8f0c0d8",
    # Grocery
    "snacks": "photo-1621939514649-16e40f49a5ba",
    "beverages": "photo-1544145945-f90425380c8e",
    "cooking oil": "photo-1474979266404-7eaacbcd87c5",
    "spices": "photo-1596040033229-a9821ebd058d",
    # Health
    "vitamins": "photo-1584308666744-24a81ac47ea8",
    "first aid": "photo-1603398938378-e54eab446dd7",
    "thermometers": "photo-1584308666744-24a81ac47ea8",
    "face masks": "photo-1584634731339-252c5843e98f",
    "hand sanitizer": "photo-1584744982493-959b62e57a8d",
    # Books
    "novels": "photo-1512820790803-83ca980e343d",
    "children books": "photo-1512820790803-83ca980e343d",
    "educational books": "photo-1497633762265-9d179a990aa6",
    "notebooks": "photo-1531346878377-a5be20888e57",
    "stationery": "photo-1452860606245-08befc0ff44b",
    "backpacks": "photo-1553062407-98eeb64c6a62",
    # Pets
    "pet food": "photo-1587300003388-59208cc962cd",
    "pet toys": "photo-1587300003388-59208cc962cd",
    "pet beds": "photo-1548199973-03cce0bbc87b",
    "pet collars": "photo-1548199973-03cce0bbc87b",
    # Garden
    "garden tools": "photo-1416879595882-3373a0480b5b",
    "plant pots": "photo-1485955900006-10f4d1d31550",
    "seeds": "photo-1466692476866-aef5b6c2c0c7",
    "watering cans": "photo-1416879595882-3373a0480b5b",
    # Generic
    "best sellers": "photo-1607082348824-0a96f2a4b9da",
    "new arrivals": "photo-1441986300917-64674bd600d8",
    "top deals": "photo-1607083206869-4c7672e72a8a",
    "popular picks": "photo-1472851294608-062f824d29cc",
}

SUFFIX = "?auto=format&fit=crop&w=400&h=400&q=80"

missing = []
# names from previous extract
with open(r"d:\commercepal\new\commercepal\tmp_extract_subs.py") as _:
    pass

import subprocess, sys
names = subprocess.check_output([sys.executable, r"d:\commercepal\new\commercepal\tmp_extract_subs.py"], text=True).strip().splitlines()[1:]

for n in names:
    key = n.lower()
    if key not in PHOTOS:
        missing.append(n)

print("MISSING", len(missing))
for m in missing:
    print(" -", m)

lines = []
lines.append("  /// Curated Unsplash CDN images for filler subcategory names.")
lines.append("  static const Map<String, String> _imageBySubcategoryName = {")
for n in names:
    key = n.lower()
    photo = PHOTOS.get(key)
    if not photo:
        photo = "photo-1441986300917-64674bd600d8"  # generic shopping
    url = f"https://images.unsplash.com/{photo}{SUFFIX}"
    # escape for dart
    dart_key = key.replace("'", "\\'")
    lines.append(f"    '{dart_key}': '{url}',")
lines.append("  };")
open(r"d:\commercepal\new\commercepal\tmp_image_map.dart", "w", encoding="utf-8").write("\n".join(lines))
print("wrote tmp_image_map.dart", len(names))
