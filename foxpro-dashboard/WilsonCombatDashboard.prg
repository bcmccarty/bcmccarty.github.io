*******************************************************************************
* WILSON COMBAT PRODUCT PERFORMANCE DASHBOARD
* Visual FoxPro Database Analytics Demo
*******************************************************************************
* Purpose:  Demonstrates DBF database operations, SQL analytics, and
*           CSV export for a premium firearms manufacturer
* Author:   Demo/Teaching Example
* Version:  1.0
*******************************************************************************
* This program creates sample inventory data for Wilson Combat products
* and generates business intelligence reports including:
*   - Gross margin analysis by category
*   - Inventory valuation and weeks-of-supply
*   - Top revenue SKUs
*   - Dead stock identification
*   - Backorder exposure analysis
*******************************************************************************

CLEAR ALL
CLOSE DATABASES ALL
SET TALK OFF
SET SAFETY OFF
SET EXCLUSIVE ON
SET DATE TO MDY
SET CENTURY ON

* Define working directory for data files
LOCAL lcDataPath
lcDataPath = ADDBS(JUSTPATH(SYS(16))) + "DATA\"

* Create data directory if it doesn't exist
IF !DIRECTORY(lcDataPath)
    MD (lcDataPath)
ENDIF

CD (lcDataPath)

*******************************************************************************
* MAIN PROGRAM EXECUTION
*******************************************************************************
DO CreateTables
DO PopulateProducts
DO PopulateInventory
DO PopulateOrders
DO PopulateOrderLines

? "=========================================="
? "WILSON COMBAT PERFORMANCE DASHBOARD"
? "Report Generated: " + DTOC(DATE()) + " " + TIME()
? "=========================================="
?

DO RunGrossMarginAnalysis
DO RunInventoryValuation
DO RunTopSkusByRevenue
DO RunDeadStockReport
DO RunBackorderExposure

? "=========================================="
? "All reports exported to CSV files."
? "=========================================="

CLOSE DATABASES ALL
RETURN


*******************************************************************************
* PROCEDURE: CreateTables
* Purpose:   Creates the four main database tables with proper structure
*******************************************************************************
PROCEDURE CreateTables

    ? "Creating database tables..."

    *-- PRODUCTS table: Master product catalog
    IF FILE("PRODUCTS.DBF")
        DELETE FILE PRODUCTS.DBF
        IF FILE("PRODUCTS.CDX")
            DELETE FILE PRODUCTS.CDX
        ENDIF
    ENDIF

    CREATE TABLE PRODUCTS ( ;
        sku         C(20)   NOT NULL, ;
        descrip     C(60)   NOT NULL, ;
        category    C(25)   NOT NULL, ;
        subcategory C(25)   NOT NULL, ;
        cost        N(10,2) NOT NULL, ;
        msrp        N(10,2) NOT NULL, ;
        weight      N(6,2)  NOT NULL  ;
    )

    INDEX ON sku TAG sku
    INDEX ON category TAG category
    USE

    *-- INVENTORY table: Stock levels by warehouse
    IF FILE("INVENTORY.DBF")
        DELETE FILE INVENTORY.DBF
        IF FILE("INVENTORY.CDX")
            DELETE FILE INVENTORY.CDX
        ENDIF
    ENDIF

    CREATE TABLE INVENTORY ( ;
        sku           C(20)  NOT NULL, ;
        warehouse     C(15)  NOT NULL, ;
        onhand        I      NOT NULL, ;
        committed     I      NOT NULL, ;
        reorder_pt    I      NOT NULL  ;
    )

    INDEX ON sku TAG sku
    INDEX ON warehouse TAG warehouse
    USE

    *-- ORDERS table: Order headers
    IF FILE("ORDERS.DBF")
        DELETE FILE ORDERS.DBF
        IF FILE("ORDERS.CDX")
            DELETE FILE ORDERS.CDX
        ENDIF
    ENDIF

    CREATE TABLE ORDERS ( ;
        order_id    C(12)  NOT NULL, ;
        order_date  D      NOT NULL, ;
        customer_id C(10)  NOT NULL, ;
        status      C(15)  NOT NULL, ;
        ship_date   D               ;
    )

    INDEX ON order_id TAG order_id
    INDEX ON order_date TAG ord_date
    INDEX ON customer_id TAG cust_id
    USE

    *-- ORDERLINE table: Order line items
    IF FILE("ORDERLINE.DBF")
        DELETE FILE ORDERLINE.DBF
        IF FILE("ORDERLINE.CDX")
            DELETE FILE ORDERLINE.CDX
        ENDIF
    ENDIF

    CREATE TABLE ORDERLINE ( ;
        order_id    C(12)   NOT NULL, ;
        sku         C(20)   NOT NULL, ;
        qty         I       NOT NULL, ;
        unit_price  N(10,2) NOT NULL, ;
        line_total  N(12,2) NOT NULL  ;
    )

    INDEX ON order_id TAG order_id
    INDEX ON sku TAG sku
    USE

    ? "  Tables created successfully."
    ?

ENDPROC


*******************************************************************************
* PROCEDURE: PopulateProducts
* Purpose:   Inserts realistic Wilson Combat product data
* Notes:     Pricing reflects actual premium firearms market (2024)
*******************************************************************************
PROCEDURE PopulateProducts

    ? "Populating PRODUCTS table..."

    USE PRODUCTS EXCLUSIVE

    *==========================================================================
    * 1911 PISTOLS - Wilson Combat's flagship products
    *==========================================================================

    *-- CQB (Close Quarters Battle) Series
    INSERT INTO PRODUCTS VALUES ( ;
        "CQB-FS-45", ;
        "CQB Full-Size .45 ACP 5in Barrel", ;
        "1911 Pistols", "CQB Series", ;
        1850.00, 3295.00, 2.56 )

    INSERT INTO PRODUCTS VALUES ( ;
        "CQB-ELITE-45", ;
        "CQB Elite Full-Size .45 ACP Armor-Tuff", ;
        "1911 Pistols", "CQB Series", ;
        2100.00, 3695.00, 2.56 )

    INSERT INTO PRODUCTS VALUES ( ;
        "CQB-CMDR-45", ;
        "CQB Commander .45 ACP 4.25in Barrel", ;
        "1911 Pistols", "CQB Series", ;
        1850.00, 3295.00, 2.31 )

    INSERT INTO PRODUCTS VALUES ( ;
        "CQB-CMPT-45", ;
        "CQB Compact .45 ACP 4in Officer Frame", ;
        "1911 Pistols", "CQB Series", ;
        1900.00, 3395.00, 2.19 )

    *-- EDC (Every Day Carry) Series
    INSERT INTO PRODUCTS VALUES ( ;
        "EDC-X9-9MM", ;
        "EDC X9 9mm Double Stack 15+1", ;
        "1911 Pistols", "EDC Series", ;
        1650.00, 2895.00, 1.81 )

    INSERT INTO PRODUCTS VALUES ( ;
        "EDC-X9L-9MM", ;
        "EDC X9L 9mm Long Slide 5in", ;
        "1911 Pistols", "EDC Series", ;
        1750.00, 3095.00, 1.94 )

    INSERT INTO PRODUCTS VALUES ( ;
        "EDC-X9S-9MM", ;
        "EDC X9S 9mm Subcompact 3.25in", ;
        "1911 Pistols", "EDC Series", ;
        1700.00, 2995.00, 1.56 )

    *-- Tactical Supergrade Series (Top Tier)
    INSERT INTO PRODUCTS VALUES ( ;
        "TSG-FS-45", ;
        "Tactical Supergrade Full-Size .45 ACP", ;
        "1911 Pistols", "Supergrade", ;
        2450.00, 4295.00, 2.56 )

    INSERT INTO PRODUCTS VALUES ( ;
        "TSG-CMDR-45", ;
        "Tactical Supergrade Commander .45 ACP", ;
        "1911 Pistols", "Supergrade", ;
        2450.00, 4295.00, 2.31 )

    INSERT INTO PRODUCTS VALUES ( ;
        "CSG-FS-45", ;
        "Classic Supergrade Full-Size .45 ACP", ;
        "1911 Pistols", "Supergrade", ;
        2650.00, 4695.00, 2.56 )

    *-- Combat Elite Series
    INSERT INTO PRODUCTS VALUES ( ;
        "CE-PRO-45", ;
        "Combat Elite Professional .45 ACP", ;
        "1911 Pistols", "Combat Elite", ;
        1950.00, 3495.00, 2.31 )

    INSERT INTO PRODUCTS VALUES ( ;
        "CE-PRO-9MM", ;
        "Combat Elite Professional 9mm", ;
        "1911 Pistols", "Combat Elite", ;
        1950.00, 3495.00, 2.31 )

    *==========================================================================
    * AR-15 RIFLES AND COMPONENTS
    *==========================================================================

    *-- Complete Rifles
    INSERT INTO PRODUCTS VALUES ( ;
        "AR15-RECON-556", ;
        "Recon Tactical 5.56 NATO 16in", ;
        "AR-15 Rifles", "Complete Rifles", ;
        1450.00, 2595.00, 6.75 )

    INSERT INTO PRODUCTS VALUES ( ;
        "AR15-RANGER-556", ;
        "Ranger 5.56 NATO 18in SS Barrel", ;
        "AR-15 Rifles", "Complete Rifles", ;
        1550.00, 2795.00, 7.25 )

    INSERT INTO PRODUCTS VALUES ( ;
        "AR15-ULTRA-556", ;
        "Ultralight Ranger 5.56 14.7in P/W", ;
        "AR-15 Rifles", "Complete Rifles", ;
        1650.00, 2995.00, 5.90 )

    INSERT INTO PRODUCTS VALUES ( ;
        "AR15-SBR-300", ;
        "SBR Tactical .300 Blackout 10.5in", ;
        "AR-15 Rifles", "Complete Rifles", ;
        1750.00, 3195.00, 5.50 )

    INSERT INTO PRODUCTS VALUES ( ;
        "AR15-PROT-556", ;
        "Protector Series 5.56 16in Carbine", ;
        "AR-15 Rifles", "Complete Rifles", ;
        1150.00, 1995.00, 6.50 )

    *-- Upper Receivers
    INSERT INTO PRODUCTS VALUES ( ;
        "AR15-UPPER-556-16", ;
        "Complete Upper 5.56 16in Mid-Length", ;
        "AR-15 Rifles", "Upper Receivers", ;
        650.00, 1195.00, 3.25 )

    INSERT INTO PRODUCTS VALUES ( ;
        "AR15-UPPER-556-14", ;
        "Complete Upper 5.56 14.5in Carbine", ;
        "AR-15 Rifles", "Upper Receivers", ;
        625.00, 1145.00, 3.00 )

    INSERT INTO PRODUCTS VALUES ( ;
        "AR15-UPPER-300-10", ;
        "Complete Upper .300BLK 10.5in Pistol", ;
        "AR-15 Rifles", "Upper Receivers", ;
        700.00, 1295.00, 2.75 )

    INSERT INTO PRODUCTS VALUES ( ;
        "AR15-UPPER-224-20", ;
        "Complete Upper .224 Valkyrie 20in", ;
        "AR-15 Rifles", "Upper Receivers", ;
        775.00, 1445.00, 4.00 )

    *-- Lower Receivers
    INSERT INTO PRODUCTS VALUES ( ;
        "AR15-LOWER-MIL", ;
        "Mil-Spec Forged Lower Receiver", ;
        "AR-15 Rifles", "Lower Receivers", ;
        85.00, 169.00, 0.56 )

    INSERT INTO PRODUCTS VALUES ( ;
        "AR15-LOWER-BIL", ;
        "Billet Matched Lower Receiver", ;
        "AR-15 Rifles", "Lower Receivers", ;
        175.00, 329.00, 0.62 )

    *==========================================================================
    * SHOTGUNS
    *==========================================================================

    INSERT INTO PRODUCTS VALUES ( ;
        "SG-CQB-12", ;
        "CQB Tactical 12ga 18.5in Cylinder", ;
        "Shotguns", "Tactical", ;
        1650.00, 2995.00, 7.00 )

    INSERT INTO PRODUCTS VALUES ( ;
        "SG-SCTR-12", ;
        "Scattergun Tech Border Patrol 12ga", ;
        "Shotguns", "Tactical", ;
        1850.00, 3295.00, 7.25 )

    INSERT INTO PRODUCTS VALUES ( ;
        "SG-STD-12", ;
        "Standard Model 12ga 20in Improved", ;
        "Shotguns", "Sporting", ;
        1450.00, 2595.00, 7.50 )

    *==========================================================================
    * MAGAZINES
    *==========================================================================

    *-- 1911 Magazines
    INSERT INTO PRODUCTS VALUES ( ;
        "MAG-1911-45-8", ;
        "Elite Tactical Magazine .45 ACP 8rd", ;
        "Magazines", "1911 Magazines", ;
        18.50, 42.95, 0.19 )

    INSERT INTO PRODUCTS VALUES ( ;
        "MAG-1911-45-10", ;
        "Elite Tactical Magazine .45 ACP 10rd", ;
        "Magazines", "1911 Magazines", ;
        22.00, 49.95, 0.22 )

    INSERT INTO PRODUCTS VALUES ( ;
        "MAG-1911-9-10", ;
        "Elite Tactical Magazine 9mm 10rd", ;
        "Magazines", "1911 Magazines", ;
        18.50, 42.95, 0.18 )

    INSERT INTO PRODUCTS VALUES ( ;
        "MAG-EDC-X9-15", ;
        "EDC X9 Magazine 9mm 15rd", ;
        "Magazines", "1911 Magazines", ;
        24.00, 54.95, 0.21 )

    INSERT INTO PRODUCTS VALUES ( ;
        "MAG-EDC-X9-18", ;
        "EDC X9 Extended Magazine 9mm 18rd", ;
        "Magazines", "1911 Magazines", ;
        28.00, 64.95, 0.25 )

    *-- AR-15 Magazines
    INSERT INTO PRODUCTS VALUES ( ;
        "MAG-AR15-556-30", ;
        "WC Logo AR-15 Magazine 5.56 30rd", ;
        "Magazines", "AR-15 Magazines", ;
        11.00, 24.95, 0.25 )

    INSERT INTO PRODUCTS VALUES ( ;
        "MAG-AR15-556-20", ;
        "WC Logo AR-15 Magazine 5.56 20rd", ;
        "Magazines", "AR-15 Magazines", ;
        10.00, 22.95, 0.20 )

    INSERT INTO PRODUCTS VALUES ( ;
        "MAG-AR15-300-30", ;
        "WC Logo AR-15 Magazine .300BLK 30rd", ;
        "Magazines", "AR-15 Magazines", ;
        12.00, 27.95, 0.26 )

    *==========================================================================
    * 1911 PARTS AND ACCESSORIES
    *==========================================================================

    *-- Triggers and Fire Control
    INSERT INTO PRODUCTS VALUES ( ;
        "TRG-1911-ULT", ;
        "Ultralight Match Trigger .290in", ;
        "1911 Parts", "Triggers", ;
        42.00, 89.95, 0.03 )

    INSERT INTO PRODUCTS VALUES ( ;
        "TRG-1911-CMBT", ;
        "Combat Trigger Solid .320in", ;
        "1911 Parts", "Triggers", ;
        38.00, 79.95, 0.04 )

    INSERT INTO PRODUCTS VALUES ( ;
        "HAM-1911-BT", ;
        "Bullet Proof Hammer", ;
        "1911 Parts", "Hammers", ;
        48.00, 99.95, 0.06 )

    INSERT INTO PRODUCTS VALUES ( ;
        "HAM-1911-CMD", ;
        "Commander Style Hammer", ;
        "1911 Parts", "Hammers", ;
        45.00, 94.95, 0.05 )

    INSERT INTO PRODUCTS VALUES ( ;
        "SEAR-1911-BP", ;
        "Bullet Proof Sear", ;
        "1911 Parts", "Fire Control", ;
        38.00, 79.95, 0.02 )

    INSERT INTO PRODUCTS VALUES ( ;
        "DISC-1911-BP", ;
        "Bullet Proof Disconnector", ;
        "1911 Parts", "Fire Control", ;
        28.00, 59.95, 0.01 )

    *-- Safeties
    INSERT INTO PRODUCTS VALUES ( ;
        "SAFE-1911-AMB", ;
        "Ambidextrous Thumb Safety", ;
        "1911 Parts", "Safeties", ;
        55.00, 119.95, 0.08 )

    INSERT INTO PRODUCTS VALUES ( ;
        "SAFE-1911-STD", ;
        "Standard Thumb Safety Blue", ;
        "1911 Parts", "Safeties", ;
        32.00, 69.95, 0.04 )

    INSERT INTO PRODUCTS VALUES ( ;
        "GRIP-1911-BP", ;
        "Bullet Proof Grip Safety", ;
        "1911 Parts", "Safeties", ;
        65.00, 139.95, 0.12 )

    *-- Sights
    INSERT INTO PRODUCTS VALUES ( ;
        "SGT-1911-BMAR", ;
        "Battlesight Rear Adjustable Tritium", ;
        "1911 Parts", "Sights", ;
        85.00, 179.95, 0.05 )

    INSERT INTO PRODUCTS VALUES ( ;
        "SGT-1911-TRIT-F", ;
        "Tritium Front Sight .125in", ;
        "1911 Parts", "Sights", ;
        42.00, 89.95, 0.02 )

    INSERT INTO PRODUCTS VALUES ( ;
        "SGT-1911-FO-F", ;
        "Fiber Optic Front Sight Red", ;
        "1911 Parts", "Sights", ;
        28.00, 59.95, 0.02 )

    *-- Grips
    INSERT INTO PRODUCTS VALUES ( ;
        "GRP-1911-G10-BK", ;
        "G10 Starburst Grips Black Full-Size", ;
        "1911 Parts", "Grips", ;
        45.00, 99.95, 0.18 )

    INSERT INTO PRODUCTS VALUES ( ;
        "GRP-1911-G10-OD", ;
        "G10 Starburst Grips OD Green Full-Size", ;
        "1911 Parts", "Grips", ;
        45.00, 99.95, 0.18 )

    INSERT INTO PRODUCTS VALUES ( ;
        "GRP-1911-COCO", ;
        "Cocobolo Diamond Pattern Grips Full-Size", ;
        "1911 Parts", "Grips", ;
        55.00, 119.95, 0.22 )

    INSERT INTO PRODUCTS VALUES ( ;
        "GRP-1911-ELK", ;
        "Elk Horn Grips Hand Finished Full-Size", ;
        "1911 Parts", "Grips", ;
        125.00, 269.95, 0.20 )

    *-- Misc 1911 Parts
    INSERT INTO PRODUCTS VALUES ( ;
        "MAIN-1911-19", ;
        "Mainspring 19lb Flat Wire", ;
        "1911 Parts", "Springs", ;
        8.00, 17.95, 0.02 )

    INSERT INTO PRODUCTS VALUES ( ;
        "REC-1911-16", ;
        "Recoil Spring 16lb Government", ;
        "1911 Parts", "Springs", ;
        6.50, 14.95, 0.02 )

    INSERT INTO PRODUCTS VALUES ( ;
        "FPR-1911-STD", ;
        "Firing Pin Spring Standard", ;
        "1911 Parts", "Springs", ;
        4.00, 8.95, 0.01 )

    INSERT INTO PRODUCTS VALUES ( ;
        "EXT-1911-BP", ;
        "Bullet Proof Extractor Blue", ;
        "1911 Parts", "Extractors", ;
        42.00, 89.95, 0.03 )

    INSERT INTO PRODUCTS VALUES ( ;
        "EJEC-1911-STD", ;
        "Ejector Standard .45 ACP", ;
        "1911 Parts", "Ejectors", ;
        18.00, 39.95, 0.02 )

    INSERT INTO PRODUCTS VALUES ( ;
        "PLUG-1911-REV", ;
        "Reverse Plug Full-Size", ;
        "1911 Parts", "Guide Rods", ;
        22.00, 49.95, 0.06 )

    INSERT INTO PRODUCTS VALUES ( ;
        "GUIDE-1911-FS", ;
        "Full Length Guide Rod Government", ;
        "1911 Parts", "Guide Rods", ;
        35.00, 74.95, 0.12 )

    *==========================================================================
    * AR-15 PARTS AND ACCESSORIES
    *==========================================================================

    INSERT INTO PRODUCTS VALUES ( ;
        "BCG-AR15-NP3", ;
        "Bolt Carrier Group NP3 Coated", ;
        "AR-15 Parts", "BCG", ;
        165.00, 299.95, 0.69 )

    INSERT INTO PRODUCTS VALUES ( ;
        "BCG-AR15-NIB", ;
        "Bolt Carrier Group Nickel Boron", ;
        "AR-15 Parts", "BCG", ;
        145.00, 269.95, 0.69 )

    INSERT INTO PRODUCTS VALUES ( ;
        "CH-AR15-RAP", ;
        "Raptor Ambidextrous Charging Handle", ;
        "AR-15 Parts", "Charging Handles", ;
        48.00, 89.95, 0.09 )

    INSERT INTO PRODUCTS VALUES ( ;
        "CH-AR15-MIL", ;
        "Mil-Spec Charging Handle", ;
        "AR-15 Parts", "Charging Handles", ;
        12.00, 29.95, 0.08 )

    INSERT INTO PRODUCTS VALUES ( ;
        "TRG-AR15-2ST", ;
        "TTU Two Stage Match Trigger", ;
        "AR-15 Parts", "Triggers", ;
        145.00, 269.95, 0.15 )

    INSERT INTO PRODUCTS VALUES ( ;
        "TRG-AR15-CMC", ;
        "Single Stage Drop-In Trigger 3.5lb", ;
        "AR-15 Parts", "Triggers", ;
        125.00, 229.95, 0.18 )

    INSERT INTO PRODUCTS VALUES ( ;
        "HGRD-AR15-MLOK", ;
        "TRIM M-LOK Rail 15in Free Float", ;
        "AR-15 Parts", "Handguards", ;
        155.00, 279.95, 0.62 )

    INSERT INTO PRODUCTS VALUES ( ;
        "HGRD-AR15-QUAD", ;
        "T.R.I.M. Quad Rail 12in", ;
        "AR-15 Parts", "Handguards", ;
        175.00, 319.95, 0.85 )

    INSERT INTO PRODUCTS VALUES ( ;
        "STOCK-AR15-ROG", ;
        "Rogers Super-Stoc Deluxe", ;
        "AR-15 Parts", "Stocks", ;
        55.00, 99.95, 0.44 )

    INSERT INTO PRODUCTS VALUES ( ;
        "STOCK-AR15-SOP", ;
        "SOPMOD Stock Mil-Spec", ;
        "AR-15 Parts", "Stocks", ;
        68.00, 129.95, 0.56 )

    INSERT INTO PRODUCTS VALUES ( ;
        "GRIP-AR15-STB", ;
        "Starburst Pistol Grip Black", ;
        "AR-15 Parts", "Grips", ;
        28.00, 59.95, 0.15 )

    INSERT INTO PRODUCTS VALUES ( ;
        "MUZZ-AR15-556", ;
        "Q-Comp Muzzle Brake 5.56 1/2x28", ;
        "AR-15 Parts", "Muzzle Devices", ;
        52.00, 99.95, 0.12 )

    INSERT INTO PRODUCTS VALUES ( ;
        "MUZZ-AR15-FH", ;
        "Accu-Tac Flash Hider 5.56 1/2x28", ;
        "AR-15 Parts", "Muzzle Devices", ;
        38.00, 74.95, 0.10 )

    *==========================================================================
    * ACCESSORIES AND GEAR
    *==========================================================================

    INSERT INTO PRODUCTS VALUES ( ;
        "CASE-1911-BLK", ;
        "Wilson Combat Hard Pistol Case Black", ;
        "Accessories", "Cases", ;
        45.00, 89.95, 1.50 )

    INSERT INTO PRODUCTS VALUES ( ;
        "CASE-AR15-TAN", ;
        "Wilson Combat Soft Rifle Case 42in Tan", ;
        "Accessories", "Cases", ;
        85.00, 169.95, 2.25 )

    INSERT INTO PRODUCTS VALUES ( ;
        "TOOL-1911-ARM", ;
        "1911 Armorer's Tool Kit", ;
        "Accessories", "Tools", ;
        125.00, 249.95, 2.80 )

    INSERT INTO PRODUCTS VALUES ( ;
        "TOOL-AR15-ARM", ;
        "AR-15 Armorer's Tool Kit", ;
        "Accessories", "Tools", ;
        145.00, 289.95, 3.50 )

    INSERT INTO PRODUCTS VALUES ( ;
        "LUBE-WC-4OZ", ;
        "Wilson Combat Ultima-Lube II 4oz", ;
        "Accessories", "Maintenance", ;
        6.00, 14.95, 0.31 )

    INSERT INTO PRODUCTS VALUES ( ;
        "LUBE-WC-KIT", ;
        "Wilson Combat Cleaning Kit Complete", ;
        "Accessories", "Maintenance", ;
        35.00, 74.95, 1.25 )

    INSERT INTO PRODUCTS VALUES ( ;
        "HOLS-1911-OWB", ;
        "Lo-Profile II OWB Holster 1911 FS RH", ;
        "Accessories", "Holsters", ;
        65.00, 134.95, 0.35 )

    INSERT INTO PRODUCTS VALUES ( ;
        "HOLS-1911-IWB", ;
        "Ultralight Carry IWB Holster 1911 Cmdr", ;
        "Accessories", "Holsters", ;
        55.00, 114.95, 0.25 )

    INSERT INTO PRODUCTS VALUES ( ;
        "BELT-TAC-15", ;
        "WC 5-Stitch Tactical Belt 1.5in Black", ;
        "Accessories", "Belts", ;
        48.00, 99.95, 0.45 )

    *-- Apparel
    INSERT INTO PRODUCTS VALUES ( ;
        "TEE-WC-BLK-L", ;
        "Wilson Combat Logo T-Shirt Black Large", ;
        "Apparel", "Shirts", ;
        12.00, 29.95, 0.38 )

    INSERT INTO PRODUCTS VALUES ( ;
        "HAT-WC-BLK", ;
        "Wilson Combat Logo Hat Black", ;
        "Apparel", "Hats", ;
        10.00, 24.95, 0.15 )

    INSERT INTO PRODUCTS VALUES ( ;
        "PATCH-WC-LOGO", ;
        "Wilson Combat Morale Patch", ;
        "Apparel", "Patches", ;
        4.00, 9.95, 0.02 )

    USE

    ? "  Products table populated with " + TRANSFORM(RECCOUNT("PRODUCTS")) + " items."
    ?

ENDPROC


*******************************************************************************
* PROCEDURE: PopulateInventory
* Purpose:   Creates inventory records across multiple warehouses
*******************************************************************************
PROCEDURE PopulateInventory

    ? "Populating INVENTORY table..."

    LOCAL laWarehouses(3), laSKUs(100), lnI, lnJ, lcSKU
    LOCAL lnOnHand, lnCommitted, lnReorderPt

    *-- Define warehouse locations
    laWarehouses(1) = "BERRYVILLE-AR"      && Main manufacturing/HQ
    laWarehouses(2) = "DALLAS-TX"          && Southwest distribution
    laWarehouses(3) = "CHARLOTTE-NC"       && East coast distribution

    USE PRODUCTS
    SELECT sku FROM PRODUCTS INTO ARRAY laSKUs
    USE

    USE INVENTORY EXCLUSIVE

    FOR lnI = 1 TO ALEN(laSKUs)
        lcSKU = ALLTRIM(laSKUs(lnI))

        FOR lnJ = 1 TO 3
            *-- Generate realistic inventory levels based on product type
            DO CASE
                CASE "1911" $ lcSKU AND "MAG" $ lcSKU
                    *-- Magazines: high volume
                    lnOnHand    = INT(RAND() * 200) + 50
                    lnCommitted = INT(RAND() * 40)
                    lnReorderPt = 75

                CASE "-45" $ lcSKU OR "-9MM" $ lcSKU OR "EDC" $ lcSKU
                    *-- Complete pistols: lower volume, higher value
                    lnOnHand    = INT(RAND() * 15) + 3
                    lnCommitted = INT(RAND() * 8)
                    lnReorderPt = 5

                CASE "AR15-UPPER" $ lcSKU OR "AR15-LOWER" $ lcSKU
                    *-- AR receivers: medium volume
                    lnOnHand    = INT(RAND() * 30) + 10
                    lnCommitted = INT(RAND() * 15)
                    lnReorderPt = 15

                CASE "AR15-" $ lcSKU AND !("-UPPER" $ lcSKU OR "-LOWER" $ lcSKU)
                    *-- Complete AR rifles
                    lnOnHand    = INT(RAND() * 12) + 2
                    lnCommitted = INT(RAND() * 6)
                    lnReorderPt = 4

                CASE "MAG-AR15" $ lcSKU
                    *-- AR magazines: high volume
                    lnOnHand    = INT(RAND() * 300) + 100
                    lnCommitted = INT(RAND() * 80)
                    lnReorderPt = 150

                CASE "SG-" $ lcSKU
                    *-- Shotguns: low volume specialty
                    lnOnHand    = INT(RAND() * 8) + 1
                    lnCommitted = INT(RAND() * 4)
                    lnReorderPt = 3

                CASE "TRG-" $ lcSKU OR "HAM-" $ lcSKU OR "SEAR-" $ lcSKU
                    *-- Fire control parts
                    lnOnHand    = INT(RAND() * 80) + 20
                    lnCommitted = INT(RAND() * 25)
                    lnReorderPt = 30

                CASE "GRP-" $ lcSKU
                    *-- Grips
                    lnOnHand    = INT(RAND() * 50) + 15
                    lnCommitted = INT(RAND() * 15)
                    lnReorderPt = 20

                CASE "MAIN-" $ lcSKU OR "REC-" $ lcSKU OR "FPR-" $ lcSKU
                    *-- Springs: high volume consumables
                    lnOnHand    = INT(RAND() * 400) + 100
                    lnCommitted = INT(RAND() * 50)
                    lnReorderPt = 150

                CASE "BCG-" $ lcSKU
                    *-- Bolt carrier groups
                    lnOnHand    = INT(RAND() * 40) + 15
                    lnCommitted = INT(RAND() * 20)
                    lnReorderPt = 20

                CASE "LUBE-" $ lcSKU OR "PATCH-" $ lcSKU
                    *-- Consumables
                    lnOnHand    = INT(RAND() * 150) + 50
                    lnCommitted = INT(RAND() * 30)
                    lnReorderPt = 75

                CASE "TEE-" $ lcSKU OR "HAT-" $ lcSKU
                    *-- Apparel
                    lnOnHand    = INT(RAND() * 100) + 30
                    lnCommitted = INT(RAND() * 20)
                    lnReorderPt = 40

                OTHERWISE
                    *-- Default for other parts
                    lnOnHand    = INT(RAND() * 60) + 10
                    lnCommitted = INT(RAND() * 20)
                    lnReorderPt = 25
            ENDCASE

            *-- Some items randomly have backorder situations
            IF RAND() < 0.12
                lnCommitted = lnOnHand + INT(RAND() * 10) + 1
            ENDIF

            *-- Primary warehouse gets more inventory
            IF lnJ = 1
                lnOnHand    = INT(lnOnHand * 1.8)
                lnCommitted = INT(lnCommitted * 1.5)
            ENDIF

            INSERT INTO INVENTORY VALUES ( ;
                lcSKU, ;
                laWarehouses(lnJ), ;
                lnOnHand, ;
                lnCommitted, ;
                lnReorderPt )
        ENDFOR
    ENDFOR

    USE

    ? "  Inventory records created: " + TRANSFORM(RECCOUNT("INVENTORY"))
    ?

ENDPROC


*******************************************************************************
* PROCEDURE: PopulateOrders
* Purpose:   Creates realistic order history for last 6 months
*******************************************************************************
PROCEDURE PopulateOrders

    ? "Populating ORDERS table..."

    LOCAL lnOrderCount, lnI, ldOrderDate, lcStatus, ldShipDate
    LOCAL lcOrderID, lcCustID
    LOCAL laStatuses(4)

    laStatuses(1) = "SHIPPED"
    laStatuses(2) = "SHIPPED"      && Weight toward shipped
    laStatuses(3) = "PROCESSING"
    laStatuses(4) = "BACKORDER"

    lnOrderCount = 850

    USE ORDERS EXCLUSIVE

    FOR lnI = 1 TO lnOrderCount
        *-- Generate order date within last 180 days
        ldOrderDate = DATE() - INT(RAND() * 180)

        *-- Generate order ID (format: WC-YYMMDD-####)
        lcOrderID = "WC-" + ;
                    PADL(YEAR(ldOrderDate) - 2000, 2, "0") + ;
                    PADL(MONTH(ldOrderDate), 2, "0") + ;
                    PADL(DAY(ldOrderDate), 2, "0") + "-" + ;
                    PADL(lnI, 4, "0")

        *-- Generate customer ID (format: C#####)
        lcCustID = "C" + PADL(INT(RAND() * 50000) + 10000, 5, "0")

        *-- Determine order status based on age
        IF (DATE() - ldOrderDate) > 7
            *-- Older orders mostly shipped
            IF RAND() < 0.92
                lcStatus = "SHIPPED"
                ldShipDate = ldOrderDate + INT(RAND() * 5) + 1
            ELSE
                lcStatus = "BACKORDER"
                ldShipDate = {//}
            ENDIF
        ELSE
            *-- Recent orders may be processing
            lcStatus = laStatuses(INT(RAND() * 4) + 1)
            IF lcStatus = "SHIPPED"
                ldShipDate = ldOrderDate + INT(RAND() * 3) + 1
            ELSE
                ldShipDate = {//}
            ENDIF
        ENDIF

        INSERT INTO ORDERS VALUES ( ;
            lcOrderID, ;
            ldOrderDate, ;
            lcCustID, ;
            lcStatus, ;
            ldShipDate )
    ENDFOR

    USE

    ? "  Orders created: " + TRANSFORM(RECCOUNT("ORDERS"))
    ?

ENDPROC


*******************************************************************************
* PROCEDURE: PopulateOrderLines
* Purpose:   Creates line items for each order with realistic product mix
*******************************************************************************
PROCEDURE PopulateOrderLines

    ? "Populating ORDERLINE table..."

    LOCAL laOrders(1000), laSKUs(100), laCosts(100), laMSRPs(100)
    LOCAL lnI, lnJ, lnLineCount, lcOrderID, lcSKU
    LOCAL lnQty, lnUnitPrice, lnLineTotal, lnSKUIdx
    LOCAL laCategories(7), lnCatWeight

    *-- Product category weights (determines sales mix)
    *-- More parts/accessories sell than complete guns
    laCategories(1) = "1911 Pistols"   && 15% of orders
    laCategories(2) = "AR-15 Rifles"   && 12% of orders
    laCategories(3) = "Magazines"      && 25% of orders
    laCategories(4) = "1911 Parts"     && 22% of orders
    laCategories(5) = "AR-15 Parts"    && 12% of orders
    laCategories(6) = "Accessories"    && 10% of orders
    laCategories(7) = "Shotguns"       && 4% of orders

    USE ORDERS
    SELECT order_id FROM ORDERS INTO ARRAY laOrders
    USE

    USE PRODUCTS
    SELECT sku, cost, msrp FROM PRODUCTS INTO ARRAY laSKUs
    USE

    USE PRODUCTS
    lnProdCount = 0
    SCAN
        lnProdCount = lnProdCount + 1
        DIMENSION laCosts(lnProdCount)
        DIMENSION laMSRPs(lnProdCount)
        laCosts(lnProdCount) = cost
        laMSRPs(lnProdCount) = msrp
    ENDSCAN
    USE

    USE ORDERLINE EXCLUSIVE

    FOR lnI = 1 TO ALEN(laOrders)
        lcOrderID = ALLTRIM(laOrders(lnI))

        *-- Random number of line items per order (1-6, weighted toward lower)
        lnLineCount = INT(RAND() * 3) + 1
        IF RAND() < 0.2
            lnLineCount = lnLineCount + INT(RAND() * 3)
        ENDIF

        FOR lnJ = 1 TO lnLineCount
            *-- Select random SKU (with category weighting)
            lnSKUIdx = INT(RAND() * ALEN(laSKUs)) + 1
            IF lnSKUIdx > ALEN(laSKUs)
                lnSKUIdx = ALEN(laSKUs)
            ENDIF

            lcSKU = ALLTRIM(laSKUs(lnSKUIdx))

            *-- Quantity based on product type
            DO CASE
                CASE "MAG-" $ lcSKU
                    *-- Magazines often bought in multiples
                    lnQty = INT(RAND() * 4) + 1
                    IF RAND() < 0.15
                        lnQty = lnQty + 3
                    ENDIF

                CASE "MAIN-" $ lcSKU OR "REC-" $ lcSKU OR "FPR-" $ lcSKU
                    *-- Springs sometimes bought in bulk
                    lnQty = INT(RAND() * 3) + 1

                CASE "LUBE-" $ lcSKU OR "PATCH-" $ lcSKU
                    *-- Consumables
                    lnQty = INT(RAND() * 2) + 1

                OTHERWISE
                    *-- Most items bought individually
                    lnQty = 1
            ENDCASE

            *-- Unit price is MSRP with occasional dealer discount
            lnUnitPrice = laMSRPs(lnSKUIdx)
            IF RAND() < 0.15
                lnUnitPrice = ROUND(lnUnitPrice * 0.90, 2)  && 10% dealer discount
            ENDIF

            lnLineTotal = lnQty * lnUnitPrice

            INSERT INTO ORDERLINE VALUES ( ;
                lcOrderID, ;
                lcSKU, ;
                lnQty, ;
                lnUnitPrice, ;
                lnLineTotal )
        ENDFOR
    ENDFOR

    USE

    ? "  Order lines created: " + TRANSFORM(RECCOUNT("ORDERLINE"))
    ?

ENDPROC


*******************************************************************************
* PROCEDURE: RunGrossMarginAnalysis
* Purpose:   Analyzes gross margin by product category
*******************************************************************************
PROCEDURE RunGrossMarginAnalysis

    ? "GROSS MARGIN ANALYSIS BY CATEGORY"
    ? REPLICATE("-", 75)

    LOCAL lcSQL

    TEXT TO lcSQL TEXTMERGE NOSHOW
        SELECT
            P.category,
            COUNT(DISTINCT P.sku) AS sku_count,
            SUM(OL.line_total) AS total_revenue,
            SUM(OL.qty * P.cost) AS total_cost,
            SUM(OL.line_total) - SUM(OL.qty * P.cost) AS gross_profit,
            ROUND((SUM(OL.line_total) - SUM(OL.qty * P.cost)) /
                  SUM(OL.line_total) * 100, 2) AS margin_pct
        FROM ORDERLINE OL
        INNER JOIN PRODUCTS P ON OL.sku = P.sku
        GROUP BY P.category
        ORDER BY gross_profit DESC
        INTO CURSOR crsMargin
    ENDTEXT

    &lcSQL

    ? PADR("Category", 20) + ;
      PADL("SKUs", 8) + ;
      PADL("Revenue", 14) + ;
      PADL("Cost", 14) + ;
      PADL("Profit", 14) + ;
      PADL("Margin%", 10)
    ? REPLICATE("-", 75)

    SELECT crsMargin
    SCAN
        ? PADR(category, 20) + ;
          PADL(TRANSFORM(sku_count), 8) + ;
          PADL("$" + TRANSFORM(total_revenue, "999,999,999.99"), 14) + ;
          PADL("$" + TRANSFORM(total_cost, "999,999,999.99"), 14) + ;
          PADL("$" + TRANSFORM(gross_profit, "999,999,999.99"), 14) + ;
          PADL(TRANSFORM(margin_pct, "999.99") + "%", 10)
    ENDSCAN

    *-- Export to CSV
    COPY TO GrossMarginByCategory.csv TYPE CSV

    USE IN SELECT("crsMargin")

    ?
    ? "  Exported to: GrossMarginByCategory.csv"
    ?

ENDPROC


*******************************************************************************
* PROCEDURE: RunInventoryValuation
* Purpose:   Calculates inventory value and weeks of supply
*******************************************************************************
PROCEDURE RunInventoryValuation

    ? "INVENTORY VALUATION & WEEKS OF SUPPLY"
    ? REPLICATE("-", 85)

    LOCAL lcSQL

    *-- First, calculate average weekly sales by SKU
    TEXT TO lcSQL TEXTMERGE NOSHOW
        SELECT
            sku,
            SUM(qty) AS total_sold,
            SUM(qty) / 26.0 AS weekly_avg
        FROM ORDERLINE
        INTO CURSOR crsSales
        GROUP BY sku
    ENDTEXT

    &lcSQL

    *-- Now calculate inventory metrics
    TEXT TO lcSQL TEXTMERGE NOSHOW
        SELECT
            P.category,
            COUNT(DISTINCT I.sku) AS sku_count,
            SUM(I.onhand) AS total_units,
            SUM(I.onhand * P.cost) AS inv_at_cost,
            SUM(I.onhand * P.msrp) AS inv_at_retail,
            SUM(I.committed) AS total_committed,
            SUM(I.onhand) - SUM(I.committed) AS available,
            ROUND(SUM(I.onhand * P.cost) /
                  NULLIF(SUM(S.weekly_avg * P.cost), 0), 1) AS weeks_supply
        FROM INVENTORY I
        INNER JOIN PRODUCTS P ON I.sku = P.sku
        LEFT JOIN crsSales S ON I.sku = S.sku
        GROUP BY P.category
        ORDER BY inv_at_cost DESC
        INTO CURSOR crsInvValue
    ENDTEXT

    &lcSQL

    ? PADR("Category", 18) + ;
      PADL("SKUs", 6) + ;
      PADL("Units", 9) + ;
      PADL("Inv@Cost", 13) + ;
      PADL("Inv@Retail", 13) + ;
      PADL("Committed", 10) + ;
      PADL("Avail", 8) + ;
      PADL("Wks Sup", 8)
    ? REPLICATE("-", 85)

    LOCAL lnTotalCost, lnTotalRetail
    lnTotalCost = 0
    lnTotalRetail = 0

    SELECT crsInvValue
    SCAN
        ? PADR(category, 18) + ;
          PADL(TRANSFORM(sku_count), 6) + ;
          PADL(TRANSFORM(total_units, "999,999"), 9) + ;
          PADL("$" + TRANSFORM(inv_at_cost, "999,999,999"), 13) + ;
          PADL("$" + TRANSFORM(inv_at_retail, "999,999,999"), 13) + ;
          PADL(TRANSFORM(total_committed, "999,999"), 10) + ;
          PADL(TRANSFORM(available, "999,999"), 8) + ;
          PADL(IIF(ISNULL(weeks_supply), "N/A", TRANSFORM(weeks_supply, "9999.9")), 8)

        lnTotalCost = lnTotalCost + inv_at_cost
        lnTotalRetail = lnTotalRetail + inv_at_retail
    ENDSCAN

    ? REPLICATE("-", 85)
    ? PADR("TOTAL INVENTORY:", 33) + ;
      PADL("$" + TRANSFORM(lnTotalCost, "999,999,999"), 13) + ;
      PADL("$" + TRANSFORM(lnTotalRetail, "999,999,999"), 13)

    *-- Export to CSV
    COPY TO InventoryValuation.csv TYPE CSV

    USE IN SELECT("crsSales")
    USE IN SELECT("crsInvValue")

    ?
    ? "  Exported to: InventoryValuation.csv"
    ?

ENDPROC


*******************************************************************************
* PROCEDURE: RunTopSkusByRevenue
* Purpose:   Identifies top 10 SKUs by total revenue
*******************************************************************************
PROCEDURE RunTopSkusByRevenue

    ? "TOP 10 SKUS BY REVENUE"
    ? REPLICATE("-", 95)

    LOCAL lcSQL

    TEXT TO lcSQL TEXTMERGE NOSHOW
        SELECT TOP 10
            OL.sku,
            P.descrip,
            P.category,
            SUM(OL.qty) AS units_sold,
            SUM(OL.line_total) AS total_revenue,
            SUM(OL.line_total - (OL.qty * P.cost)) AS total_profit,
            ROUND((SUM(OL.line_total - (OL.qty * P.cost)) /
                   SUM(OL.line_total)) * 100, 1) AS margin_pct
        FROM ORDERLINE OL
        INNER JOIN PRODUCTS P ON OL.sku = P.sku
        GROUP BY OL.sku, P.descrip, P.category
        ORDER BY total_revenue DESC
        INTO CURSOR crsTopSKUs
    ENDTEXT

    &lcSQL

    ? PADR("SKU", 20) + ;
      PADR("Description", 35) + ;
      PADL("Units", 8) + ;
      PADL("Revenue", 14) + ;
      PADL("Profit", 12) + ;
      PADL("Margin", 8)
    ? REPLICATE("-", 95)

    LOCAL lnRank
    lnRank = 0

    SELECT crsTopSKUs
    SCAN
        lnRank = lnRank + 1
        ? TRANSFORM(lnRank, "99") + ". " + PADR(sku, 17) + ;
          PADR(LEFT(descrip, 33), 35) + ;
          PADL(TRANSFORM(units_sold, "9,999"), 8) + ;
          PADL("$" + TRANSFORM(total_revenue, "9,999,999.99"), 14) + ;
          PADL("$" + TRANSFORM(total_profit, "999,999.99"), 12) + ;
          PADL(TRANSFORM(margin_pct, "999.9") + "%", 8)
    ENDSCAN

    *-- Export full list (not just top 10) for analysis
    TEXT TO lcSQL TEXTMERGE NOSHOW
        SELECT
            OL.sku,
            P.descrip,
            P.category,
            SUM(OL.qty) AS units_sold,
            SUM(OL.line_total) AS total_revenue,
            SUM(OL.line_total - (OL.qty * P.cost)) AS total_profit,
            ROUND((SUM(OL.line_total - (OL.qty * P.cost)) /
                   SUM(OL.line_total)) * 100, 1) AS margin_pct
        FROM ORDERLINE OL
        INNER JOIN PRODUCTS P ON OL.sku = P.sku
        GROUP BY OL.sku, P.descrip, P.category
        ORDER BY total_revenue DESC
        INTO CURSOR crsAllSKUs
    ENDTEXT

    &lcSQL

    COPY TO TopSkusByRevenue.csv TYPE CSV

    USE IN SELECT("crsTopSKUs")
    USE IN SELECT("crsAllSKUs")

    ?
    ? "  Exported to: TopSkusByRevenue.csv"
    ?

ENDPROC


*******************************************************************************
* PROCEDURE: RunDeadStockReport
* Purpose:   Identifies products with no sales in 90+ days
*******************************************************************************
PROCEDURE RunDeadStockReport

    ? "DEAD STOCK REPORT (NO SALES IN 90+ DAYS)"
    ? REPLICATE("-", 85)

    LOCAL lcSQL, ldCutoffDate
    ldCutoffDate = DATE() - 90

    *-- Find last sale date for each SKU
    TEXT TO lcSQL TEXTMERGE NOSHOW
        SELECT
            OL.sku,
            MAX(O.order_date) AS last_sale_date
        FROM ORDERLINE OL
        INNER JOIN ORDERS O ON OL.order_id = O.order_id
        GROUP BY OL.sku
        INTO CURSOR crsLastSale
    ENDTEXT

    &lcSQL

    *-- Find products with no recent sales or no sales at all
    TEXT TO lcSQL TEXTMERGE NOSHOW
        SELECT
            P.sku,
            P.descrip,
            P.category,
            SUM(I.onhand) AS total_onhand,
            SUM(I.onhand * P.cost) AS inv_value,
            NVL(S.last_sale_date, {^1900-01-01}) AS last_sale,
            IIF(ISNULL(S.last_sale_date), 999, DATE() - S.last_sale_date) AS days_since_sale
        FROM PRODUCTS P
        INNER JOIN INVENTORY I ON P.sku = I.sku
        LEFT JOIN crsLastSale S ON P.sku = S.sku
        WHERE NVL(S.last_sale_date, {^1900-01-01}) < ?ldCutoffDate
          AND I.onhand > 0
        GROUP BY P.sku, P.descrip, P.category, S.last_sale_date
        HAVING SUM(I.onhand) > 0
        ORDER BY inv_value DESC
        INTO CURSOR crsDeadStock
    ENDTEXT

    &lcSQL

    IF RECCOUNT("crsDeadStock") = 0
        ? "  No dead stock identified - all products have recent sales!"
    ELSE
        ? PADR("SKU", 20) + ;
          PADR("Description", 32) + ;
          PADL("On Hand", 9) + ;
          PADL("Inv Value", 12) + ;
          PADL("Days Silent", 12)
        ? REPLICATE("-", 85)

        LOCAL lnTotalValue, lnCount
        lnTotalValue = 0
        lnCount = 0

        SELECT crsDeadStock
        SCAN
            lnCount = lnCount + 1
            lnTotalValue = lnTotalValue + inv_value

            ? PADR(sku, 20) + ;
              PADR(LEFT(descrip, 30), 32) + ;
              PADL(TRANSFORM(total_onhand, "99,999"), 9) + ;
              PADL("$" + TRANSFORM(inv_value, "999,999.99"), 12) + ;
              PADL(IIF(days_since_sale = 999, "Never", TRANSFORM(days_since_sale)), 12)
        ENDSCAN

        ? REPLICATE("-", 85)
        ? "  Dead Stock Items: " + TRANSFORM(lnCount) + ;
          "   |   Total Value at Risk: $" + TRANSFORM(lnTotalValue, "999,999.99")

        *-- Export to CSV
        COPY TO DeadStockReport.csv TYPE CSV
    ENDIF

    USE IN SELECT("crsLastSale")
    IF USED("crsDeadStock")
        USE IN SELECT("crsDeadStock")
    ENDIF

    ?
    ? "  Exported to: DeadStockReport.csv"
    ?

ENDPROC


*******************************************************************************
* PROCEDURE: RunBackorderExposure
* Purpose:   Identifies SKUs where committed quantity exceeds on-hand
*******************************************************************************
PROCEDURE RunBackorderExposure

    ? "BACKORDER EXPOSURE REPORT (COMMITTED > ON HAND)"
    ? REPLICATE("-", 90)

    LOCAL lcSQL

    TEXT TO lcSQL TEXTMERGE NOSHOW
        SELECT
            I.sku,
            P.descrip,
            P.category,
            I.warehouse,
            I.onhand,
            I.committed,
            I.committed - I.onhand AS backorder_qty,
            (I.committed - I.onhand) * P.msrp AS revenue_at_risk,
            I.reorder_pt
        FROM INVENTORY I
        INNER JOIN PRODUCTS P ON I.sku = P.sku
        WHERE I.committed > I.onhand
        ORDER BY revenue_at_risk DESC
        INTO CURSOR crsBackorder
    ENDTEXT

    &lcSQL

    IF RECCOUNT("crsBackorder") = 0
        ? "  No backorder exposure - all commitments can be fulfilled!"
    ELSE
        ? PADR("SKU", 18) + ;
          PADR("Warehouse", 15) + ;
          PADL("On Hand", 9) + ;
          PADL("Committed", 10) + ;
          PADL("B/O Qty", 9) + ;
          PADL("Rev at Risk", 13) + ;
          PADL("Reorder Pt", 11)
        ? REPLICATE("-", 90)

        LOCAL lnTotalRisk, lnTotalBO
        lnTotalRisk = 0
        lnTotalBO = 0

        SELECT crsBackorder
        SCAN
            lnTotalRisk = lnTotalRisk + revenue_at_risk
            lnTotalBO = lnTotalBO + backorder_qty

            ? PADR(sku, 18) + ;
              PADR(warehouse, 15) + ;
              PADL(TRANSFORM(onhand, "99,999"), 9) + ;
              PADL(TRANSFORM(committed, "99,999"), 10) + ;
              PADL(TRANSFORM(backorder_qty, "99,999"), 9) + ;
              PADL("$" + TRANSFORM(revenue_at_risk, "999,999.99"), 13) + ;
              PADL(TRANSFORM(reorder_pt, "99,999"), 11)
        ENDSCAN

        ? REPLICATE("-", 90)
        ? "  Total Backorder Units: " + TRANSFORM(lnTotalBO, "999,999") + ;
          "   |   Total Revenue at Risk: $" + TRANSFORM(lnTotalRisk, "9,999,999.99")

        *-- Export to CSV
        COPY TO BackorderExposure.csv TYPE CSV
    ENDIF

    USE IN SELECT("crsBackorder")

    ?
    ? "  Exported to: BackorderExposure.csv"
    ?

ENDPROC


*******************************************************************************
* END OF PROGRAM
*******************************************************************************
