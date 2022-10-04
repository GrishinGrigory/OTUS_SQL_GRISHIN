USE [WideWorldImporters]
GO

--____________________________________________________________________________________________________
/*1. ��� ������, � �������� ������� ���� "urgent" ��� �������� ���������� � "Animal".*/
SELECT [StockItemID]
      ,[StockItemName]
FROM [Warehouse].[StockItems]
where StockItemName like '%urgent%'
      or StockItemName like 'Animal%'
--____________________________________________________________________________________________________

--____________________________________________________________________________________________________
/*2.����������� (Suppliers), � ������� �� ���� ������� �� ������ ������ (PurchaseOrders).*/
select s.SupplierName, s.SupplierID
from (SELECT [SupplierName]
	  ,count(f.[PurchaseOrderID]) as Count_order
      FROM [Purchasing].[PurchaseOrders] f join [Purchasing].[Suppliers] s on f.SupplierID=s.SupplierID
      group by [SupplierName]) q right join [Purchasing].[Suppliers] s on q.SupplierName=s.SupplierName
where Count_order is null
--____________________________________________________________________________________________________

--____________________________________________________________________________________________________
/*3. ������ (Orders) � ����� ������ (UnitPrice) ����� 100$ 
���� ����������� ������ (Quantity) ������ ����� 20 ����
� �������������� ����� ������������ ����� ������ (PickingCompletedWhen).*/
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
/* ������� � ��������� ������ 1000 � ������� ��������� 100*/
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
/*4.������ ����������� (Purchasing.Suppliers), ������� ������ ���� ��������� (ExpectedDeliveryDate) � ������ 2013 ����
� ��������� "Air Freight" ��� "Refrigerated Air Freight" (DeliveryMethodName)
� ������� ��������� (IsOrderFinalized).*/

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
/*5. ������ ��������� ������ (�� ���� �������) � ������ ������� � ������ ����������, ������� ������� ����� (SalespersonPerson).
������� ��� �����������.*/
SELECT top 10 CustomerName
      ,FullName as [SalespersonPerson]
FROM [Sales].[Orders] f  join [Sales].[Customers] s on f.CustomerID=s.CustomerID
                         join [Application].[People] t on f.SalespersonPersonID = t.PersonID
order by OrderDate desc
--____________________________________________________________________________________________________

--____________________________________________________________________________________________________
/*6. ��� �� � ����� �������� � �� ���������� ��������, ������� �������� ����� "Chocolate frogs 250g".
��� ������ �������� � ������� Warehouse.StockItems. */
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
