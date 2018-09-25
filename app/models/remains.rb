
module Remains
  class MyError < StandardError
    attr_reader :thing
    def initialize(msg="My default message", thing="apple")
      @thing = thing
      self.send_notify(msg)
      super(msg)
    end

    def send_notify(msg)
      mail = Mail.new do
        from     'root@tplast.org'
        to       'avatar48@yandex.ru'
        subject  'Ошибки при отправки остатков'
        body     msg
      end
      mail.deliver!
    end
  end

  class Worker
    QUERY = <<-here
SELECT  stock = 'Зарайск', [ITEM CODE] as code,  [ITEM NAME] as name,[UNIT CODE] as unit,
amount =  case WHEN [KV-DARGEZ] > 0 THEN [KV-DARGEZ] ELSE 0 END
FROM  (SELECT TOP (100) PERCENT dbo.LG_001_ITEMS.LOGICALREF AS SREF, dbo.LG_001_UNITSETF.LOGICALREF AS USEF,
dbo.LG_001_ITEMS.CODE AS [ITEM CODE], dbo.LG_001_ITEMS.NAME AS [ITEM NAME],
dbo.LG_001_UNITSETF.CODE AS [UNIT CODE],
(SELECT  SUM(ONHAND) AS Expr1
FROM dbo.LG_001_01_STINVTOT AS LG_001_01_STINVTOT_5 WITH (NOLOCK, INDEX = I001_01_STINVTOT_I2)
WHERE (dbo.LG_001_ITEMS.LOGICALREF = STOCKREF) AND (INVENNO = 0) AND (DATE_ > CONVERT(dateTime, '5-19-1919', 101))  and (DATE_ <= CONVERT(dateTime, '#{Time.now.month}-#{Time.now.day}-#{Time.now.year}', 101))   )
AS [KV-DARGEZ]                                                 
FROM dbo.LG_001_ITEMS WITH (NOLOCK, INDEX = I001_ITEMS_I1) INNER JOIN
dbo.LG_001_UNITSETF WITH (NOLOCK, INDEX = I001_UNITSETF_I1) ON
dbo.LG_001_ITEMS.UNITSETREF = dbo.LG_001_UNITSETF.LOGICALREF
WHERE  (dbo.LG_001_ITEMS.CARDTYPE IN (1, 12)) AND (dbo.LG_001_ITEMS.ACTIVE = 0) and MINIMAX = 1
GROUP BY dbo.LG_001_ITEMS.LOGICALREF, dbo.LG_001_UNITSETF.LOGICALREF, dbo.LG_001_ITEMS.CODE, dbo.LG_001_ITEMS.NAME, dbo.LG_001_UNITSETF.CODE) AS A
GROUP BY  [ITEM CODE], [UNIT CODE], [ITEM NAME],[KV-DARGEZ]
order by [ITEM CODE]
here

    attr_reader :query
  
    def initialize()
      @query_text = QUERY
    end

    def connect
      @client = TinyTds::Client.new username: ENV['USERNAME'], password: ENV['PASSWORD'], host: ENV['HOST'], database: ENV['DATABASE']
    end

    def active?
      @client.active?
    end
    
    def execute
      @client.execute(@query_text)
    end
    
    def self.to_xml(obj)
      a = Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
        xml.send(:"Остатки на #{Time.now}"){
          obj.each do |single|
            xml.send(:'СтрокаТовары') {
              xml.send(:"Склад", single["stock"])
              xml.send(:"Артикул", single["code"])
              xml.send(:"Наименование", single["name"])
              xml.send(:"Единица измерения", single["unit"])
              xml.send(:"Количество", single["amount"])
            }
          end
        }
      end
      HTMLEntities.new.decode(a.to_xml)
    end
  end
end




 