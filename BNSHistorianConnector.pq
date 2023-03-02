// This file contains your Data Connector logic
[Version = "1.0.0"]
section BNSHistorianConnector;

[DataSource.Kind="BNSHistorianConnector", Publish="BNSHistorianConnector.Publish"]
shared BNSHistorianConnector.Contents = Value.ReplaceType(HistorianImpl, HistorianType);

HistorianType = type function(
    url as (type text meta [
        Documentation.FieldCaption = "URL",
        Documentation.FieldDescription = "URL of the web content",
        Documentation.SampleValues = {"127.0.0.1"}
        ]),
    port as (type text meta [
        Documentation.FieldCaption = "Port",
        Documentation.FieldDescription = "Port number",
        Documentation.SampleValues = {8080}
        ]),
    call as (type text meta [
        Documentation.FieldCaption = "Call",
        Documentation.FieldDescription = "HTTP call method",
        Documentation.AllowedValues = {"Point/GetPoint?", "Point/GetPoints?", "Point/GetPointsRaw?"}
        ]),
    holdtype as (type text meta [
        Documentation.FieldCaption = "Hold Type",
        Documentation.FieldDescription = "Hold Type Selection",
        Documentation.SampleValues = {"0"}
        ]),
    interval as (type text meta [
        Documentation.FieldCaption = "Interval",
        Documentation.FieldDescription = "Interval of tag data points",
        Documentation.SampleValues = {"600"}
        ]),
    headers as (type record meta [
        Documentation.FieldCaption = "Headers",
        Documentation.FieldDescription = "HTTP headers",
        Documentation.SampleValues = [#"Content-Type" = "application/json-patch+json"],
        IsAdvanced = true
        ]),
    tags as (type list meta [
        Documentation.FieldCaption = "Tags",
        Documentation.FieldDescription = "List of tags that needs to be queried. The list needs to to imported first. This needs to selected from a table.",
        Documentation.SampleValues = {"Tag Table Name"},
        IsAdvanced = true
        ]))
    as table meta [
        Documentation.Name = "BNS Historian Connector",
        Documentation.LongDescription = "BNS Historian Connector",
        Documentation.Description = "This function retrieves the tag values of the specified list from the Blue Nickel Historian"
        ];

DefaultRequestHeaders = [
    #"Content-Type" = "application/json-patch+json"
   ];

DefaultDateQuery = [
    query = [startDate=DateTime.ToText(Date.AddDays(DateTime.From(DateTime.LocalNow()), -1), "yyyy'-'MM'-'dd'T'06':'00':'00"), endDate=DateTime.ToText((DateTime.LocalNow()), "yyyy'-'MM'-'dd'T'06':'00':'00")]
]; 

TagsList = (tagsList as list) =>
    let
        source = List.Combine(tagsList, ","),
        returnedTags = Text.ToBinary(source)
    in
        returnedTags;

HistorianImpl = (url as text, port as text, call as text, holdtype as text, interval as text, headers as record, body as list) =>
    let
        bodyContent = Json.FromValue(body),
        combinedUrl = Uri.Combine(url, port),
        // Use the Web.Contents function to get the web content from the specified URL and port number
        response = Web.Contents(combinedUrl, [
            Headers = headers,
            Query = [
                call = call,
                interval = interval,
                holdType = holdtype,
                startDate=DateTime.ToText(Date.AddDays(DateTime.From(DateTime.LocalNow()), -1), "yyyy'-'MM'-'dd'T'06':'00':'00"),
                endDate=DateTime.ToText((DateTime.LocalNow()), "yyyy'-'MM'-'dd'T'06':'00':'00")
            ],
            Content = bodyContent
        ])
    in
        response;

BNSHistorianConnector = [
    TestConnection = (BNSHistorianConnector.Feed) => 
        let
		    params = Json.Document(BNSHistorianConnector.Feed),
		    startDate = params[startDate],
		    endDate = params[endDate]
	    in
		    {startDate, endDate},

    Authentication = [
        // Key = [],
        UsernamePassword = [],
        Windows = [SupportsAlternateCredentials = true],
        Anonymous = []
    ]
];


// // Data Source UI publishing description
BNSHistorianConnector.Publish = [
    Beta = true,
    Category = "Other",
    ButtonText = { Extension.LoadString("ButtonTitle"), Extension.LoadString("ButtonHelp") },
    LearnMoreUrl = "https://www.bluenickel.co.za/",
    SourceImage = BNSHistorianConnector.Icons,
    SourceTypeImage = BNSHistorianConnector.Icons
];

BNSHistorianConnector.Icons = [
    Icon16 = { Extension.Contents("collect_16.png"), Extension.Contents("collect_20.png"), Extension.Contents("collect_24.png"), Extension.Contents("collect_32.png") },
    Icon32 = { Extension.Contents("collect_32.png"), Extension.Contents("collect_40.png"), Extension.Contents("collect_48.png"), Extension.Contents("collect_64.png") }
];