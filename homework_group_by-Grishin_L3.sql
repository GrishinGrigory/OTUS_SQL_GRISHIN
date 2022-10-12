/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.
Занятие "02 - Оператор SELECT и простые фильтры, GROUP BY, HAVING".

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
-- ---------------------------------------------------------------------------

USE WideWorldImporters

/*
1. Посчитать среднюю цену товара, общую сумму продажи по месяцам.
Вывести:
* Год продажи (например, 2015)
* Месяц продажи (например, 4)
* Средняя цена за месяц по всем товарам
* Общая сумма продаж за месяц

Продажи смотреть в таблице Sales.Invoices и связанных таблицах.
*/

SELECt YEAR ([InvoiceDate]) Year_invoice
	  ,MONTH([InvoiceDate]) Month_invoice
	  ,AVG([UnitPrice]) as Average_price
	  ,Sum([UnitPrice]) as Sum_price 
  FROM [Sales].[Invoices] f join Sales.InvoiceLines s on f.InvoiceID=s.InvoiceID 
group by  YEAR ([InvoiceDate]),MONTH([InvoiceDate])
order by YEAR ([InvoiceDate]),MONTH([InvoiceDate])

/*
2. Отобразить все месяцы, где общая сумма продаж превысила 4 600 000

Вывести:
* Год продажи (например, 2015)
* Месяц продажи (например, 4)
* Общая сумма продаж

Продажи смотреть в таблице Sales.Invoices и связанных таблицах.
*/
/* тут мне не ясно, по сути это тот же самый способ как и в задании 1 только надо применить Having,
Но анализируя выборку из прошлого кода там нет ни одного месяца который попадал бы под критерий. Что я упускаю?*/

SELECt YEAR ([InvoiceDate]) Year_invoice
	  ,MONTH([InvoiceDate]) Month_invoice
	  ,Sum([UnitPrice]) as Sum_price 
  FROM [Sales].[Invoices] f join Sales.InvoiceLines s on f.InvoiceID=s.InvoiceID 
group by  YEAR ([InvoiceDate]),  MONTH([InvoiceDate])
having Sum([UnitPrice]) >4600000
order by YEAR ([InvoiceDate]),MONTH([InvoiceDate])

/*
3. Вывести сумму продаж, дату первой продажи
и количество проданного по месяцам, по товарам,
продажи которых менее 50 ед в месяц.
Группировка должна быть по году,  месяцу, товару.

Вывести:
* Год продажи
* Месяц продажи
* Наименование товара
* Сумма продаж
* Дата первой продажи
* Количество проданного

Продажи смотреть в таблице Sales.Invoices и связанных таблицах.
*/

SELECt YEAR ([InvoiceDate]) Year_invoice
	  ,MONTH([InvoiceDate]) Month_invoice
	  ,Description
	  ,Sum([UnitPrice]) as Sum_price
	  ,min([InvoiceDate]) as Fist_invoise
	  ,count([StockItemID]) as count_item
  FROM [Sales].[Invoices] f join Sales.InvoiceLines s on f.InvoiceID=s.InvoiceID 
group by  YEAR ([InvoiceDate]),  MONTH([InvoiceDate]), Description
having count([StockItemID]) < 50
order by YEAR ([InvoiceDate]),MONTH([InvoiceDate])

-- ---------------------------------------------------------------------------
-- Опционально
-- ---------------------------------------------------------------------------
/*
Написать запросы 2-3 так, чтобы если в каком-то месяце не было продаж,
то этот месяц также отображался бы в результатах, но там были нули.
*/
