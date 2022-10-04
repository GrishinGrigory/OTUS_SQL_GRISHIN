USE [WideWorldImporters]
GO

--____________________________________________________________________________________________________
/*1. Âñå òîâàðû, â íàçâàíèè êîòîðûõ åñòü "urgent" èëè íàçâàíèå íà÷èíàåòñÿ ñ "Animal".*/
SELECT [StockItemID]
      ,[StockItemName]
FROM [Warehouse].[StockItems]
where StockItemName like '%urgent%'
      or StockItemName like 'Animal%'
--____________________________________________________________________________________________________

--____________________________________________________________________________________________________
/*2.Ïîñòàâùèêîâ (Suppliers), ó êîòîðûõ íå áûëî ñäåëàíî íè îäíîãî çàêàçà (PurchaseOrders).*/
select s.SupplierName, s.SupplierID
from (SELECT [SupplierName]
	  ,count(f.[PurchaseOrderID]) as Count_order
      FROM [Purchasing].[PurchaseOrders] f join [Purchasing].[Suppliers] s on f.SupplierID=s.SupplierID
      group by [SupplierName]) q right join [Purchasing].[Suppliers] s on q.SupplierName=s.SupplierName
where Count_order is null
--____________________________________________________________________________________________________

--____________________________________________________________________________________________________
/*3. Çàêàçû (Orders) ñ öåíîé òîâàðà (UnitPrice) áîëåå 100$ 
ëèáî êîëè÷åñòâîì åäèíèö (Quantity) òîâàðà áîëåå 20 øòóê
è ïðèñóòñòâóþùåé äàòîé êîìïëåêòàöèè âñåãî çàêàçà (PickingCompletedWhen).*/

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
/* âàðèàíò ñ ïðîïóñêîì ïåðâûõ 1000 è âûâîäîì ñëåäóþùèõ 100*/

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
/*4.Çàêàçû ïîñòàâùèêàì (Purchasing.Suppliers), êîòîðûå äîëæíû áûòü èñïîëíåíû (ExpectedDeliveryDate) â ÿíâàðå 2013 ãîäà
ñ äîñòàâêîé "Air Freight" èëè "Refrigerated Air Freight" (DeliveryMethodName)
è êîòîðûå èñïîëíåíû (IsOrderFinalized).*/

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
--___________________________________________________________________________________________________

--____________________________________________________________________________________________________
/*5. Äåñÿòü ïîñëåäíèõ ïðîäàæ (ïî äàòå ïðîäàæè) ñ èìåíåì êëèåíòà è èìåíåì ñîòðóäíèêà, êîòîðûé îôîðìèë çàêàç (SalespersonPerson).
Ñäåëàòü áåç ïîäçàïðîñîâ.*/
SELECT top 10 CustomerName
      ,FullName as [SalespersonPerson]
FROM [Sales].[Orders] f  join [Sales].[Customers] s on f.CustomerID=s.CustomerID
                         join [Application].[People] t on f.SalespersonPersonID = t.PersonID
order by OrderDate desc
--____________________________________________________________________________________________________

--____________________________________________________________________________________________________
/*6. Âñå èä è èìåíà êëèåíòîâ è èõ êîíòàêòíûå òåëåôîíû, êîòîðûå ïîêóïàëè òîâàð "Chocolate frogs 250g".
Èìÿ òîâàðà ñìîòðåòü â òàáëèöå Warehouse.StockItems. */
SELECT lvl3.[CustomerID]
      ,[CustomerName]
      ,[PhoneNumber]
  FROM [Sales].[Customers] lvl3 join (SELECT distinct [CustomerID]
                                    fROM [Sales].[Invoices] lvl2 join (SELECT distinct [InvoiceID]
                                                                     FROM [Sales].[InvoiceLines] lvl1 join [Warehouse].[StockItems] s on lvl1.StockItemID= s.StockItemID
                                                                     where StockItemName like '%Chocolate frogs 250g%') step1 on lvl2.InvoiceID=step1.InvoiceID) step2 on lvl3.CustomerID=step2.CustomerID
--____________________________________________________________________________________________________
