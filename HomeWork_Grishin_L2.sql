USE [WideWorldImporters]
GO

--____________________________________________________________________________________________________
/*1. ¬се товары, в названии которых есть "urgent" или название начинаетс€ с "Animal".*/
SELECT [StockItemID]
      ,[StockItemName]
FROM [Warehouse].[StockItems]
where StockItemName like '%urgent%'
      or StockItemName like 'Animal%'
--____________________________________________________________________________________________________

--____________________________________________________________________________________________________
/*2.ѕоставщиков (Suppliers), у которых не было сделано ни одного заказа (PurchaseOrders).*/
select s.SupplierName, s.SupplierID
from (SELECT [SupplierName]
	  ,count(f.[PurchaseOrderID]) as Count_order
      FROM [Purchasing].[PurchaseOrders] f join [Purchasing].[Suppliers] s on f.SupplierID=s.SupplierID
      group by [SupplierName]) q right join [Purchasing].[Suppliers] s on q.SupplierName=s.SupplierName
where Count_order is null
--____________________________________________________________________________________________________

--____________________________________________________________________________________________________
/*3. «аказы (Orders) с ценой товара (UnitPrice) более 100$ 
либо количеством единиц (Quantity) товара более 20 штук
и присутствующей датой комплектации всего заказа (PickingCompletedWhen).*/
SELECT [OrderID]
      ,format([OrderDate],'dd/MM/yyyy') as date_order
	  ,datename(mm,[OrderDate]) as Month
	  ,datename(qq,[OrderDate]) as Qartal
	  ,case when MONTH([OrderDate]) between 1 and 4 then 1
	        when MONTH([OrderDate]) between 5 and 8 then 2
			else 3
       end as Triens    
      ,CustomerName as Customer
FROM [Sales].[Orders]f join [Sales].[Customers] s on f.CustomerID=s.CustomerID 
where OrderID in (SELECT [OrderID] FROM [Sales].[OrderLines]
                  where UnitPrice >100
                  group by OrderID)
   or OrderID in (SELECT [OrderID] FROM [Sales].[OrderLines]
                  where Quantity> 20 and [PickingCompletedWhen] is null
                  group by [OrderID]) 
order by 4,5,2
/* вариант с пропуском первых 1000 и выводом следующих 100*/
SELECT [OrderID]
      ,format([OrderDate],'dd/MM/yyyy') as date_order
	  ,datename(mm,[OrderDate]) as Month
	  ,datename(qq,[OrderDate]) as Qartal
	  ,case when MONTH([OrderDate]) between 1 and 4 then 1
	        when MONTH([OrderDate]) between 5 and 8 then 2
			else 3
       end as Triens    
      ,CustomerName as Customer
FROM [Sales].[Orders]f join [Sales].[Customers] s on f.CustomerID=s.CustomerID 
where OrderID in (SELECT [OrderID] FROM [Sales].[OrderLines]
                  where UnitPrice >100
                  group by OrderID)
   or OrderID in (SELECT [OrderID] FROM [Sales].[OrderLines]
                  where Quantity> 20 and [PickingCompletedWhen] is null
                  group by [OrderID]) 
order by 4,5,2
OFFSET 1000 ROWS FETCH NEXT 100 ROWS ONLY

--____________________________________________________________________________________________________
/*4.«аказы поставщикам (Purchasing.Suppliers), которые должны быть исполнены (ExpectedDeliveryDate) в €нваре 2013 года
с доставкой "Air Freight" или "Refrigerated Air Freight" (DeliveryMethodName)
и которые исполнены (IsOrderFinalized).*/

SELECT [DeliveryMethodName]
	  ,[ExpectedDeliveryDate]
	  ,SupplierName
      ,FullName as  [ContactPerson]
  FROM [Purchasing].[PurchaseOrders] f join [Application].[DeliveryMethods] s on f.DeliveryMethodID=s.DeliveryMethodID
                                       join [Purchasing].[Suppliers] t on f.SupplierID=t.SupplierID
									   join [Application].[People] q on f.ContactPersonID = q.PersonID
where ExpectedDeliveryDate between '2013-01-01' and '2013-01-31'
 and IsOrderFinalized  = 1
 and ([DeliveryMethodName] like '%Air Freight%' or [DeliveryMethodName] like '%Refrigerated Air Freight%')
--____________________________________________________________________________________________________

--____________________________________________________________________________________________________
/*5. ƒес€ть последних продаж (по дате продажи) с именем клиента и именем сотрудника, который оформил заказ (SalespersonPerson).
—делать без подзапросов.*/
SELECT top 10 CustomerName
      ,FullName as [SalespersonPerson]
FROM [Sales].[Orders] f  join [Sales].[Customers] s on f.CustomerID=s.CustomerID
                         join [Application].[People] t on f.SalespersonPersonID = t.PersonID
order by OrderDate desc
--____________________________________________________________________________________________________

--____________________________________________________________________________________________________
/*6. ¬се ид и имена клиентов и их контактные телефоны, которые покупали товар "Chocolate frogs 250g".
»м€ товара смотреть в таблице Warehouse.StockItems. */
SELECT [CustomerID]
      ,[CustomerName]
      ,[PhoneNumber]
  FROM [Sales].[Customers]
where CustomerID in (SELECT distinct [CustomerID]
                     FROM [Sales].[Invoices] 
                     where InvoiceID in (SELECT distinct [InvoiceID]
                                         FROM [Sales].[InvoiceLines] f join [Warehouse].[StockItems] s on f.StockItemID= s.StockItemID
                                         where StockItemName like '%Chocolate frogs 250g%'))
--____________________________________________________________________________________________________
