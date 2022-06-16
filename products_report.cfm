<!---Ürün Listesi Rapor Çalışması/Max Satır Sayısı, Sayfa Geçiş---->

<div>
<h1 style="color:#A52A2A; margin-left: 50px;">Ürün Listesi Rapor Çalışması</h1>
</div>

<style>
#customers {
  margin: 50px;
  font-family: Arial, Helvetica, sans-serif;
  border-collapse: collapse;
  width: 94.5%;
  overflow:auto;
}

#customers td, #customers th {
  border: 1px solid #ddd;
  padding: 8px;
}

#customers tr:nth-child(even){background-color: #f2f2f2;}

#customers tr:hover {background-color: #ddd;}
#customers th:hover, button:hover {background-color: #008080;}

#customers th {
  padding-top: 12px;
  padding-bottom: 12px;
  text-align: left;
  background-color: #04AA6D;
  color: white;
}

button {
  border: 1px solid #ddd;
  padding: 8px;
  padding-top: 8px;
  padding-bottom: 8px;
  text-align: right;
  background-color: #04AA6D;
  color: white;
}

.column {
  float: left;
  width: 40%;
  padding: 10px;
  height: auto; /* Should be removed. Only for demonstration */
  font-size:20px;
}

/* Clear floats after the columns */
.row:after {
  content: "";
  display: table;
  clear: both;
}

.right {
  position: absolute;
  right: 50px;
  width: auto;
  padding: 10px;
    font-size:20px;
}
</style>

<cffunction  name="urun_function" returntype="any" output="yes">
  <cfargument name="cari_adı_argument" default="">

<cfquery name="products_query" datasource="#DSN1#" result="products_query_result" maxrows="50">

  SELECT  DISTINCT  
    BARCOD AS BARKOD,
    PRODUCT_CODE_2 AS URUN_NO,
    PRODUCT_NAME AS URUN_ADI,
    CASE
        WHEN P.PROJECT_ID IS NOT NULL THEN PROJECT_NUMBER
        ELSE OZEL_KOD
    END AS CARI_NO,
    CASE
        WHEN P.PROJECT_ID IS NOT NULL THEN PROJECT_HEAD
        ELSE NICKNAME
    END AS CARI_ADI,
    PRODUCT_CODE AS KATEGORI,
    BRAND_NAME AS MARKA,
    TAX AS KDV,
    PR.PRICE_KDV AS SATIS_FIYAT

  FROM catalyst_cosmetica_product.PRODUCT P

  LEFT JOIN catalyst_cosmetica.COMPANY C ON C.COMPANY_ID = P.COMPANY_ID
  LEFT JOIN catalyst_cosmetica_product.PRODUCT_BRANDS B ON B.BRAND_ID = P.BRAND_ID
  LEFT JOIN catalyst_cosmetica.PRO_PROJECTS PP ON PP.PROJECT_ID = P.PROJECT_ID
  LEFT JOIN catalyst_cosmetica_1.PRICE PR ON PR.PRODUCT_ID = P.PRODUCT_ID

  WHERE NICKNAME NOT LIKE '%DELİST%' --SQL'de tanımlı sütun başlık adı girilmeli, sorguda yapılan adlandırma (CARI_ADI) ile çalışmıyor
  AND NICKNAME LIKE '%#arguments.cari_adı_argument#%' OR PROJECT_HEAD LIKE '%#arguments.cari_adı_argument#%'

  ORDER BY PRODUCT_CODE_2

</cfquery>

  <cfreturn products_query>
    
</cffunction>

<cfparam name="attributes.cari_adı_attribute" default="">
<cfparam name="attributes.maks_satır_sayısı" default="20"> 
<cfparam name="attributes.bulunulan_sayfa" default="1">   

<cfset func_calistir= urun_function(cari_adı_argument:"#attributes.cari_adı_attribute#")>
<!---
<div style="margin-left: 50px;">
  <cfdump  var="#products_query_result#">
</div>
--->
<div style="margin:50px;">

  <cfform name="cari_ara" method="post" action="https://catalyst.cosmetica.com.tr/index.cfm?fuseaction=report.detail_report&event=det&report_id=16"> <!---http adres--->
    <table>
      <tr>
        <td>Cari Adı Filtre</td>
        <td><cfinput type="text" name="cari_adı_attribute" value="#attributes.cari_adı_attribute#"></td>  <!---value="#attributes.cari_adı_attribute#" ile arama yapılmış olan kelime, text giriş alanında görülür--->
        <td><cfinput type="text" name="maks_satır_sayısı"  validate="integer" required="yes" message="Sayfalama Hatalı!" value="#attributes.maks_satır_sayısı#" style="width:25px;"></td> 
        <td><input type="submit" value="Ara">
      </tr>
    </table>
  </cfform>
<!---
  <cfdump  var="#attributes#">  <!---filtre alanına bir kelime girip arama yaptığımızda, attribute listesinde "cari_adı_attribute" görünür. Kelime girip ara demeden önce attributes listesinde “cari_adı_attribute” görünmez (cfparam ile default bir tanım da yapılmadı ise) --->
--->
</div>

<!---excel dosyası oluşturma----->
<!---
<cfspreadsheet action="write" fileName="ürün_listesi_query.xls" query="products_query" 
sheetname="ürün_bilgileri" overwrite=true> 

<a href="ürün_listesi_query.xls" download>Download</a>  
---->

<table id="customers">
  <th>BARKOD</th>
  <th>ÜRÜN NO</th>
  <th>ÜRÜN ADI</th>
  <th>CARİ NO </th>
  <th>CARİ ADI</th>
  <th>KATEGORİ NO</th>
  <th>GRUP ADI</th>
  <th>ALT GRUP ADI</th>
  <th>SINIF</th>
  <th>MARKA</th>
  <th>KDV</th>
  <th>SATIŞ FİYAT</th>
  <cfoutput query="products_query" startrow="#((attributes.bulunulan_sayfa * attributes.maks_satır_sayısı)-attributes.maks_satır_sayısı)+1#" maxrows="#attributes.maks_satır_sayısı#">
    <tr>
      <td>#BARKOD#</td>
      <td>#URUN_NO#</td>
      <td>#URUN_ADI#</td>
      <td>#CARI_NO#</td>
      <td>#CARI_ADI#</td>     
      <td>#KATEGORI#</td>
      <td>
        <cfif       left(KATEGORI,3) contains '002'> Aksesuar
          <cfelseif left(KATEGORI,3) contains '003'> Diğer
          <cfelseif left(KATEGORI,3) contains '01.'> Makyaj
          <cfelseif left(KATEGORI,3) contains '02.'> Cilt Bakım Ürünleri
          <cfelseif left(KATEGORI,3) contains '05.'> Saç Bakım
          <cfelseif left(KATEGORI,3) contains '08.'> Kişisel Bakım Ürünleri
          <cfelseif left(KATEGORI,3) contains '09.'> Ağız Bakım Ürünleri
          <cfelseif left(KATEGORI,3) contains '10.'> Parfüm
          <cfelseif left(KATEGORI,3) contains '11.'> Deodorant
          <cfelseif left(KATEGORI,3) contains '12.'> Erkek Bakım Ürünleri
          <cfelseif left(KATEGORI,3) contains '13.'> Bebek Bakım Ürünleri
          <cfelseif left(KATEGORI,2) contains '4.'> Ev Temizliği Ürünleri
          <cfelseif left(KATEGORI,2) contains '6.'> Telekomünikasyon
          <cfelse>  Tanımsız
        </cfif>
      </td> 
      <td>Tanımlanmadı</td>
      <td>Tanımlanmadı</td>
      <td>#MARKA#</td>
      <td>#KDV#</td>
      <td>#SATIS_FIYAT#</td>
    </tr>
  </cfoutput>
</table>

<div class="row" style="margin:50px;">
<cfoutput>
<div class="column">
    <b><a href="https://catalyst.cosmetica.com.tr/index.cfm?fuseaction=report.detail_report&event=det&report_id=16&
cari_adı_attribute=#attributes.cari_adı_attribute#&
<!---http adres sonuna "&maks_satır_sayısı=#attributes.maks_satır_sayısı#" ekleyerek, bir önceki sayfada girilmiş olan maks_satır_sayısı da işlenmiş olur--->
maks_satır_sayısı=#attributes.maks_satır_sayısı#
<!---http adres sonuna "&maks_satır_sayısı=#attributes.maks_satır_sayısı#" ekleyerek, bir önceki sayfada girilmiş olan maks_satır_sayısı da işlenmiş olur--->
&bulunulan_sayfa=#attributes.bulunulan_sayfa-1#"><button>Geri</button></a></b>
</div>
<div class="column, right">
    <b><a href="https://catalyst.cosmetica.com.tr/index.cfm?fuseaction=report.detail_report&event=det&report_id=16&
cari_adı_attribute=#attributes.cari_adı_attribute#&
<!---http adres sonuna "&maks_satır_sayısı=#attributes.maks_satır_sayısı#" ekleyerek, bir önceki sayfada girilmiş olan maks_satır_sayısı da işlenmiş olur--->
maks_satır_sayısı=#attributes.maks_satır_sayısı#
<!---http adres sonuna "&maks_satır_sayısı=#attributes.maks_satır_sayısı#" ekleyerek, bir önceki sayfada girilmiş olan maks_satır_sayısı da işlenmiş olur--->
&bulunulan_sayfa=#attributes.bulunulan_sayfa+1#"><button>İleri</button></a></b>
</div>
</cfoutput>
</div>
<!----tabloya göre excel dosyası oluşturma (products_query içeriğine göre ancak products_query içeriğinde olmayan verileri tanımlayarak)--->
<!---
<cfset news = queryNew("BARKOD,URUN_NO,GRUP_ADI", "varchar,varchar,varchar")> <!---yeni query tanımlama--->
<cfloop from="1" to="#products_query.recordCount()#" index="i"> <!---yeni query hücrelerini tanımlama döngüsü----->
<cfset record=QueryGetRow(products_query,i)>  <!---products_query'den veri çekme ---->
<cfset queryAddRow(news)> <!---yeni boş satır ekleme---->
<cfset querySetCell(news, "BARKOD", "#record.BARKOD#")> <!---satır hücrelerini, products_query'den çekilen veriler ile tanımlama----->
<cfset querySetCell(news, "URUN_NO", "#record.URUN_NO#")>
          <cfif     left("#record.KATEGORI#",3) contains '002'> <cfset category ="Aksesuar"> <!---products_query içeriğine göre ancak products_query içeriğinde olmayan bir veriyi tanımlama---->
          <cfelseif left("#record.KATEGORI#",3) contains '003'> <cfset category ="Diğer">
          <cfelseif left("#record.KATEGORI#",3) contains '01.'> <cfset category ="Makyaj">
          <cfelseif left("#record.KATEGORI#",3) contains '02.'> <cfset category ="Cilt Bakım Ürünleri">
          <cfelseif left("#record.KATEGORI#",3) contains '05.'> <cfset category ="Saç Bakım">
          <cfelseif left("#record.KATEGORI#",3) contains '08.'> <cfset category ="Kişisel Bakım Ürünleri">
          <cfelseif left("#record.KATEGORI#",3) contains '09.'> <cfset category ="Ağız Bakım Ürünleri">
          <cfelseif left("#record.KATEGORI#",3) contains '10.'> <cfset category ="Parfüm">
          <cfelseif left("#record.KATEGORI#",3) contains '11.'> <cfset category ="Deodorant">
          <cfelseif left("#record.KATEGORI#",3) contains '12.'> <cfset category ="Erkek Bakım Ürünleri">
          <cfelseif left("#record.KATEGORI#",3) contains '13.'> <cfset category ="Bebek Bakım Ürünleri">
          <cfelseif left("#record.KATEGORI#",2) contains '4.'> <cfset category ="Ev Temizliği Ürünleri">
          <cfelseif left("#record.KATEGORI#",2) contains '6.'> <cfset category ="Telekomünikasyon">
          <cfelse> <cfset category ="Tanımsız">
          </cfif>
<cfset querySetCell(news, "GRUP_ADI","#category#")> <!---cfif ile tanımlanan veriyi hücreye tanımlama----->
</cfloop>

<cfspreadsheet  action="write" filename="ürün_listesi_table.xls" query="news" sheetname="urun_bilgileri" overwrite="true">

<a href="ürün_listesi_table.xls" download>Download</a>  
--->

