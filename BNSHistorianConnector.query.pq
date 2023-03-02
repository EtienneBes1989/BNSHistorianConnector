// Use this file to write queries to test your data connector
let
    result = BNSHistorianConnector.Contents("127.0.0.1","9099","Point/GetPoints","600",{"[Chrome]A200_PIT_CYC201.Eng","[Chrome]A200_PIC_CYC201.SP","[Chrome]A200_LIT_TNK201.Eng","[Chrome]A200_LIC_TNK201.SP"})
in
    result
