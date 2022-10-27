
If OBJECT_ID('tempdb..##Sales') >0
Begin
    Drop Table ##Sales
End
Select Data.*
into ##Sales
from (
select orderdate,OrderQty as UnitSales, linetotal as SalesAmount, (linetotal - (orderqty * pch.standardcost)) as Revenue
, cr.[name] as Country, p.[name] as productname, CustomerID, SalesPersonID, sod.SalesOrderID, datename(month,orderdate) as OrderMonth,
case when datepart(year,orderdate) = '2011' then 'FY11'
when datepart(year,orderdate) = '2012' then 'FY12'
when datepart(year,orderdate) = '2013' then 'FY13'
when datepart(year,orderdate) = '2014' then 'FY14' end as 'Fiscal'
,pc.Name as Productcategory
from sales.salesorderdetail as sod
inner join sales.SalesOrderHeader as soh  on soh.SalesOrderID = sod.SalesOrderID
left join production.ProductCostHistory as pch on 
datepart(year,soh.OrderDate) = datepart(year,pch.startDate) and pch.ProductID = sod.ProductID
left join sales.SalesTerritory as st on st.TerritoryID = soh.TerritoryID
left join person.CountryRegion as cr on st.CountryRegionCode = cr.CountryRegionCode
inner join production.product as p on p.ProductID = sod.ProductID
left join Production.productsubcategory as psc on  p.ProductSubcategoryID= psc.ProductSubcategoryID
inner join Production.productcategory as pc on pc.ProductCategoryID = psc.ProductCategoryID
)as data




If OBJECT_ID('tempdb..##units') >0
Begin
    Drop Table ##units
End
Select Data.*
into ##units
from (
	Select *
	from(
	Select unitSales as UnitSales,OrderMonth,fiscal,
	Country,productname,Productcategory
	from ##Sales
	where Fiscal in ('FY11','FY12','FY13','FY14')
	--and country = 'germany' and ordermonth = 'november' and fiscal ='fy11'
	) as tablepivot
	pivot 
	(
	sum(unitSales)
	for fiscal in ([FY11],[FY12],[FY13],[FY14])
	 )as p
	 )as data

	 



 If OBJECT_ID('tempdb..##SalesAmount') >0
Begin
    Drop Table ##SalesAmount
End
Select Data.*
into ##SalesAmount
from (
Select *
from(
Select SalesAmount as SalesAmount,OrderMonth,fiscal,
Country,productname
from ##Sales
where Fiscal in ('FY11','FY12','FY13','FY14')
--and country = 'germany' and ordermonth = 'november' and fiscal ='fy11'
) as tablepivot
pivot 
(
sum(SalesAmount)
for fiscal in ([FY11],[FY12],[FY13],[FY14])
 )as p
 )as data



 If OBJECT_ID('tempdb..##Revenue') >0
Begin
    Drop Table ##Revenue
End
Select Data.*
into ##Revenue
from (
Select *
from(
Select Revenue as Revenue,OrderMonth,fiscal,
Country,productname
from ##Sales
where Fiscal in ('FY11','FY12','FY13','FY14')
--and country = 'germany' and ordermonth = 'november' and fiscal ='fy11'
) as tablepivot
pivot 
(
sum(Revenue)
for fiscal in ([FY11],[FY12],[FY13],[FY14])
 )as p
 )as data

 Select u.ordermonth, u.country, isnull(u.fy11,0) as FY11Units, isnull(u.fy12,0) as FY12Units, isnull(u.FY13,0) AS FY13Units, isnull(U.FY14,0) as FY14Units,
 isnull(sa.fy11,0) as FY11SalesValue, isnull(sa.fy12,0) as FY12SalesValue, isnull(sa.FY13,0) AS FY13SalesValue, isnull(sa.FY14,0) as FY14SalesValue,
 isnull(r.fy11,0) as FY11Revenue, isnull(r.fy12,0) as FY12Revenue, isnull(r.FY13,0) AS FY13Revenue, isnull(r.FY14,0) as FY14Revenue
 ,u.productname,u.ProductCategory
 from ##units as u
 left join ##SalesAmount as sa on u.Country = sa.Country and u.OrderMonth = sa.OrderMonth and u.productname = sa.productname
 left join ##revenue as r on u.Country = r.Country and u.OrderMonth = r.OrderMonth and u.productname = r.productname

