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

SELECT f.[OrderID]
      ,format([OrderDate],'dd/MM/yyyy') as date_order
	  ,datename(mm,[OrderDate]) as Month
	  ,datename(qq,[OrderDate]) as Qartal
	  ,case when MONTH([OrderDate]) between 1 and 4 then 1
	        when MONTH([OrderDate]) between 5 and 8 then 2
			else 3
       end as Triens    
      ,CustomerName as Customer
FROM [Sales].[Orders]f join [Sales].[Customers] s on f.CustomerID=s.CustomerID 
                       join (select iif (q1.OrderID is null,q2.OrderID,q1.OrderID) as OrderID 
                             from (SELECT [OrderID] FROM [Sales].[OrderLines]
                                   where UnitPrice >100
                                   group by OrderID) q1 full join (SELECT [OrderID] FROM [Sales].[OrderLines]
                                                                   where Quantity> 20 and [PickingCompletedWhen] is null
                                                                   group by [OrderID]) q2 on q1.OrderID=q2.OrderID) t on f.OrderID=t.OrderID

order by Qartal,Triens,date_order
/* вариант с пропуском первых 1000 и выводом следующих 100*/

SELECT f.[OrderID]
      ,format([OrderDate],'dd/MM/yyyy') as date_order
	  ,datename(mm,[OrderDate]) as Month
	  ,datename(qq,[OrderDate]) as Qartal
	  ,case when MONTH([OrderDate]) between 1 and 4 then 1
	        when MONTH([OrderDate]) between 5 and 8 then 2
			else 3
       end as Triens    
      ,CustomerName as Customer
FROM [Sales].[Orders]f join [Sales].[Customers] s on f.CustomerID=s.CustomerID 
                       join (select iif (q1.OrderID is null,q2.OrderID,q1.OrderID) as OrderID 
                             from (SELECT [OrderID] FROM [Sales].[OrderLines]
                                   where UnitPrice >100
                                   group by OrderID) q1 full join (SELECT [OrderID] FROM [Sales].[OrderLines]
                                                                   where Quantity> 20 and [PickingCompletedWhen] is null
                                                                   group by [OrderID]) q2 on q1.OrderID=q2.OrderID) t on f.OrderID=t.OrderID

order by Qartal,Triens,date_order
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
 and ([DeliveryMethodName] ='Air Freight' or [DeliveryMethodName] = 'Refrigerated Air Freight')
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
SELECT lvl3.[CustomerID]
      ,[CustomerName]
      ,[PhoneNumber]
  FROM [Sales].[Customers] lvl3 join (SELECT distinct [CustomerID]
                                    fROM [Sales].[Invoices] lvl2 join (SELECT distinct [InvoiceID]
                                                                     FROM [Sales].[InvoiceLines] lvl1 join [Warehouse].[StockItems] s on lvl1.StockItemID= s.StockItemID
                                                                     where StockItemName like '%Chocolate frogs 250g%') step1 on lvl2.InvoiceID=step1.InvoiceID) step2 on lvl3.CustomerID=step2.CustomerID
--____________________________________________________________________________________________________
