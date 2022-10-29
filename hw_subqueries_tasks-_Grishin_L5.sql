/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "03 - Подзапросы, CTE, временные таблицы".

Задания выполняются с использованием базы данных WideWorldImporters.

Бэкап БД можно скачать отсюда:
https://github.com/Microsoft/sql-server-samples/releases/tag/wide-world-importers-v1.0
Нужен WideWorldImporters-Full.bak

Описание WideWorldImporters от Microsoft:
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-what-is
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-oltp-database-catalog
*/

-- ---------------------------------------------------------------------------
-- Задание - написать выборки для получения указанных ниже данных.
-- Для всех заданий, где возможно, сделайте два варианта запросов:
--  1) через вложенный запрос
--  2) через WITH (для производных таблиц)
-- ---------------------------------------------------------------------------

USE WideWorldImporters

/*
1. Выберите сотрудников (Application.People), которые являются продажниками (IsSalesPerson), 
и не сделали ни одной продажи 04 июля 2015 года. 
Вывести ИД сотрудника и его полное имя. 
Продажи смотреть в таблице Sales.Invoices.
*/

TODO: 
/* Подзапрос*/
SELECT [PersonID]
      ,[FullName]
FROM [Application].[People]
where IsSalesperson = 1
and PersonID not in (SELECT [SalespersonPersonID]
                     FROM [Sales].[Invoices]
                     where InvoiceDate = '2015-07-04');
/*CTE*/
with  
salelist as 
(SELECT [SalespersonPersonID]
        ,FullName
  FROM [Sales].[Invoices] f join [Application].[People] s on f.SalespersonPersonID=s.PersonID 
where InvoiceDate = '2015-07-04'),
personList as 
(SELECT [PersonID]
       ,[FullName]
FROM [Application].[People]
where IsSalesperson = 1)

select [PersonID],[FullName]
from personList
except
select [SalespersonPersonID] ,FullName
from salelist;

/*
2. Выберите товары с минимальной ценой (подзапросом). Сделайте два варианта подзапроса. 
Вывести: ИД товара, наименование товара, цена.
*/
/*Тут я не понял, из какой таблицы. Склад или продажи?*/
TODO: 
SELECT [StockItemID]
      ,[Description]
      ,[UnitPrice]
FROM [Sales].[InvoiceLines]
where [UnitPrice] =  (SELECt min([UnitPrice]) as [UnitPrice]
                      FROM [Sales].[InvoiceLines])

/*это  на складе*/
SELECT [StockItemID]
      ,[StockItemName]
      ,[UnitPrice]
FROM [Warehouse].[StockItems]
Where [UnitPrice] = (SELECT  min([UnitPrice]) as [UnitPrice]
                     FROM [Warehouse].[StockItems])

/*не совсем понимаю как это можно сделать с зависимым подзапросом */
SELECT [StockItemID]
      ,[Description]
      ,(SELECT min([UnitPrice]) as [UnitPrice]
               FROM [Warehouse].[StockItems]
	    where [StockItems].StockItemID=[InvoiceLines].StockItemID) as [UnitPrice]
  FROM [Sales].[InvoiceLines]

/*
3. Выберите информацию по клиентам, которые перевели компании пять максимальных платежей 
из Sales.CustomerTransactions. 
Представьте несколько способов (в том числе с CTE). 
*/

TODO: 
/*подзапрос*/
SELECT f.[CustomerID]
      ,[CustomerName]
      ,[BillToCustomerID]
      ,[CustomerCategoryID]
      ,[BuyingGroupID]
      ,[PrimaryContactPersonID]
      ,[AlternateContactPersonID]
      ,[DeliveryMethodID]
      ,[DeliveryCityID]
      ,[PostalCityID]
      ,[CreditLimit]
      ,[AccountOpenedDate]
      ,[StandardDiscountPercentage]
      ,[IsStatementSent]
      ,[IsOnCreditHold]
      ,[PaymentDays]
      ,[PhoneNumber]
      ,[FaxNumber]
      ,[DeliveryRun]
      ,[RunPosition]
      ,[WebsiteURL]
      ,[DeliveryAddressLine1]
      ,[DeliveryAddressLine2]
      ,[DeliveryPostalCode]
      ,[DeliveryLocation]
      ,[PostalAddressLine1]
      ,[PostalAddressLine2]
      ,[PostalPostalCode]
      ,[LastEditedBy]
      ,[ValidFrom]
      ,[ValidTo]
  FROM [Sales].[Customers]  f join (SELECT [CustomerID]
                                   ,max([AmountExcludingTax]) as MAX_PAY
                                   FROM [Sales].[CustomerTransactions]
                                   group by [CustomerID] ) s on f.CustomerID=s.CustomerID
ORDER BY MAX_PAY DESC
OFFSET 0 ROWS FETCH NEXT 5 ROWS ONLY
/* CTE */
;
with get_max as (
SELECT [CustomerID]
,max([AmountExcludingTax]) as MAX_PAY
FROM [Sales].[CustomerTransactions]
group by [CustomerID] ),
get_cusdata as (
SELECT [CustomerID]
      ,[CustomerName]
      ,[BillToCustomerID]
      ,[CustomerCategoryID]
      ,[BuyingGroupID]
      ,[PrimaryContactPersonID]
      ,[AlternateContactPersonID]
      ,[DeliveryMethodID]
      ,[DeliveryCityID]
      ,[PostalCityID]
      ,[CreditLimit]
      ,[AccountOpenedDate]
      ,[StandardDiscountPercentage]
      ,[IsStatementSent]
      ,[IsOnCreditHold]
      ,[PaymentDays]
      ,[PhoneNumber]
      ,[FaxNumber]
      ,[DeliveryRun]
      ,[RunPosition]
      ,[WebsiteURL]
      ,[DeliveryAddressLine1]
      ,[DeliveryAddressLine2]
      ,[DeliveryPostalCode]
      ,[DeliveryLocation]
      ,[PostalAddressLine1]
      ,[PostalAddressLine2]
      ,[PostalPostalCode]
      ,[LastEditedBy]
      ,[ValidFrom]
      ,[ValidTo]
  FROM [Sales].[Customers])
  select top 5 get_cusdata.* from get_cusdata join get_max on get_cusdata.CustomerID=get_max.CustomerID
  order by MAX_PAY desc
  ;


/*
4. Выберите города (ид и название), в которые были доставлены товары, 
входящие в тройку самых дорогих товаров, а также имя сотрудника, 
который осуществлял упаковку заказов (PackedByPersonID).
*/

TODO: 

SELECT DeliveryCityID
	  ,CityName
      ,[PackedByPersonID]
  FROM [Sales].[Invoices] f join [Sales].[Customers] s on f.CustomerID=s.CustomerID
                            join [Application].[Cities] t on s.DeliveryCityID=t.CityID
							join (SELECT [InvoiceID]
                                        ,[StockItemID]
                                        ,max([UnitPrice]) max_price
                                        FROM [Sales].[InvoiceLines]
                                        group by [StockItemID],[InvoiceID]) q on f.InvoiceID=q.InvoiceID
order by max_price desc
OFFSET 0 ROWS FETCH NEXT 3 ROWS ONLY


-- ---------------------------------------------------------------------------
-- Опциональное задание
-- ---------------------------------------------------------------------------
-- Можно двигаться как в сторону улучшения читабельности запроса, 
-- так и в сторону упрощения плана\ускорения. 
-- Сравнить производительность запросов можно через SET STATISTICS IO, TIME ON. 
-- Если знакомы с планами запросов, то используйте их (тогда к решению также приложите планы). 
-- Напишите ваши рассуждения по поводу оптимизации. 

-- 5. Объясните, что делает и оптимизируйте запрос

SELECT 
	Invoices.InvoiceID, 
	Invoices.InvoiceDate,
	(SELECT People.FullName
		FROM Application.People
		WHERE People.PersonID = Invoices.SalespersonPersonID
	) AS SalesPersonName,
	SalesTotals.TotalSumm AS TotalSummByInvoice, 
	(SELECT SUM(OrderLines.PickedQuantity*OrderLines.UnitPrice)
		FROM Sales.OrderLines
		WHERE OrderLines.OrderId = (SELECT Orders.OrderId 
			FROM Sales.Orders
			WHERE Orders.PickingCompletedWhen IS NOT NULL	
				AND Orders.OrderId = Invoices.OrderId)	
	) AS TotalSummForPickedItems
FROM Sales.Invoices 
	JOIN
	(SELECT InvoiceId, SUM(Quantity*UnitPrice) AS TotalSumm
	FROM Sales.InvoiceLines
	GROUP BY InvoiceId
	HAVING SUM(Quantity*UnitPrice) > 27000) AS SalesTotals
		ON Invoices.InvoiceID = SalesTotals.InvoiceID
ORDER BY TotalSumm DESC

-- --

TODO:
/*запрос формирует таблицу опрат где выводит номер оплаты дату подзапросом, который связан по условию, определяется имя продажника
сумма счета опроделяеться отдельным подзапросом и соеденяться обычным джоином. Сам подзапрос в джоине групперует счета по номеру заказа, считаем сумму
и ограничиваем сумму от 270000
затем двойным подзапросом формируем сумму стоимости товаров (наверное для контроля ценны)
где второй по глубине подзапрос связан с основной таблицей по полу номера заказа
таким образом считается сумма по заказу для наших считов
так же во втором, по глубине, подзапросе присутсвует допольное ограничение по колонке которое исключает пустые записи
изменил только читабельность из за нехватки времени (((((*/

SELECT 
	Invoices.InvoiceID, 
	Invoices.InvoiceDate,
	(SELECT People.FullName
	 FROM Application.People
	 WHERE People.PersonID = Invoices.SalespersonPersonID) AS SalesPersonName,
	SalesTotals.TotalSumm AS TotalSummByInvoice, 
	(SELECT SUM(OrderLines.PickedQuantity*OrderLines.UnitPrice)
	 FROM Sales.OrderLines
	 WHERE OrderLines.OrderId = (SELECT Orders.OrderId 
			                     FROM Sales.Orders
			                     WHERE Orders.PickingCompletedWhen IS NOT NULL	
				                       AND Orders.OrderId = Invoices.OrderId)	
	 ) AS TotalSummForPickedItems
FROM Sales.Invoices JOIN (SELECT InvoiceId, SUM(Quantity*UnitPrice) AS TotalSumm
	                      FROM Sales.InvoiceLines
	                      GROUP BY InvoiceId
                       	  HAVING SUM(Quantity*UnitPrice) > 27000) AS SalesTotals ON Invoices.InvoiceID = SalesTotals.InvoiceID
ORDER BY TotalSumm DESC