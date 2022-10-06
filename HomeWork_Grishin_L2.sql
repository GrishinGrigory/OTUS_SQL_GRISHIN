USE [WideWorldImporters]
GO

--____________________________________________________________________________________________________
/*1. Все товары, в названии которых есть "urgent" или название начинается с "Animal".*/
SELECT [StockItemID]
      ,[StockItemName]
FROM [Warehouse].[StockItems]
where StockItemName like '%urgent%'
      or StockItemName like 'Animal%'
--____________________________________________________________________________________________________

--____________________________________________________________________________________________________
/*2.Поставщиков (Suppliers), у которых не было сделано ни одного заказа (PurchaseOrders).*/
SELECT t.[SupplierName]
	  ,t.SupplierID
      FROM [Purchasing].[PurchaseOrders] f join [Purchasing].[Suppliers] s on f.SupplierID=s.SupplierID
	                                     right join [Purchasing].[Suppliers] t on f.SupplierID=t.SupplierID
where PurchaseOrderID is null
--____________________________________________________________________________________________________

--____________________________________________________________________________________________________
/*3. Заказы (Orders) с ценой товара (UnitPrice) более 100$ 
либо количеством единиц (Quantity) товара более 20 штук
и присутствующей датой комплектации всего заказа (PickingCompletedWhen).*/

SELECT DISTINCT f.[OrderID]
      ,format([OrderDate],'dd/MM/yyyy') as date_order
	  ,datename(mm,[OrderDate]) as Month
	  ,datename(qq,[OrderDate]) as Qartal
	  ,case when MONTH([OrderDate]) between 1 and 4 then 1
	        when MONTH([OrderDate]) between 5 and 8 then 2
			else 3
       end as Triens    
      ,CustomerName as Customer
FROM [Sales].[Orders]f join [Sales].[Customers] s on f.CustomerID=s.CustomerID 
                       join [Sales].[OrderLines] t on f.OrderID = t.OrderID
where UnitPrice >100
    or ( Quantity> 20 and t.[PickingCompletedWhen] is null)
order by Qartal,Triens,date_order

/* вариант с пропуском первых 1000 и выводом следующих 100*/
SELECT DISTINCT f.[OrderID]
      ,format([OrderDate],'dd/MM/yyyy') as date_order
	  ,datename(mm,[OrderDate]) as Month
	  ,datename(qq,[OrderDate]) as Qartal
	  ,case when MONTH([OrderDate]) between 1 and 4 then 1
	        when MONTH([OrderDate]) between 5 and 8 then 2
			else 3
       end as Triens    
      ,CustomerName as Customer
FROM [Sales].[Orders]f join [Sales].[Customers] s on f.CustomerID=s.CustomerID 
                       join [Sales].[OrderLines] t on f.OrderID = t.OrderID
where UnitPrice >100
    or ( Quantity> 20 and t.[PickingCompletedWhen] is null)
order by Qartal,Triens,date_order
OFFSET 1000 ROWS FETCH NEXT 100 ROWS ONLY


-- Сохранил на всякий случай, по причине того, что его стоимость относительно альтернативы на JOIN  17% 
/*SELECT f.[OrderID]
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
OFFSET 1000 ROWS FETCH NEXT 100 ROWS ONLY */ 


--____________________________________________________________________________________________________
/*4.Заказы поставщикам (Purchasing.Suppliers), которые должны быть исполнены (ExpectedDeliveryDate) в январе 2013 года
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
/*5. Десять последних продаж (по дате продажи) с именем клиента и именем сотрудника, который оформил заказ (SalespersonPerson).
Сделать без подзапросов.*/
SELECT top 10 CustomerName
      ,FullName as [SalespersonPerson]
FROM [Sales].[Orders] f  join [Sales].[Customers] s on f.CustomerID=s.CustomerID
                         join [Application].[People] t on f.SalespersonPersonID = t.PersonID
order by OrderDate desc
--____________________________________________________________________________________________________

--____________________________________________________________________________________________________
/*6. Все ид и имена клиентов и их контактные телефоны, которые покупали товар "Chocolate frogs 250g".
Имя товара смотреть в таблице Warehouse.StockItems. */
SELECT distinct lvl3.[CustomerID]
      ,[CustomerName]
      ,[PhoneNumber]
  FROM [Sales].[Customers] lvl3 join [Sales].[Invoices] lvl2 on lvl2.CustomerID=lvl3.CustomerID
                                join [Sales].[InvoiceLines] lvl1 on lvl2.InvoiceID= lvl1.InvoiceID
								join [Warehouse].[StockItems] s on lvl1.StockItemID= s.StockItemID
where StockItemName like '%Chocolate frogs 250g%'
--____________________________________________________________________________________________________