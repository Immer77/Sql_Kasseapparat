/*
Opgave 2a
*/
SELECT Product.productNr, productName, priceValue, S.situationName from Product
Inner join Price as P
on P.productNr = Product.productNr
inner join Situation as S
on S.situationName = P.situationName
where Product.productNr = 2


/*
Opgave 2b
*/
SELECT Sale.saleNumber, SUM(ISNULL(O.fixedPrice, Pri.priceValue * O.amount * (1.0 - Pri.percentDiscount /100.0))) as total from Sale
Inner join OrderLine as O
on Sale.saleNumber = O.saleNumber
Inner join Price as Pri
on Pri.priceId = O.priceId
inner join Product as Pro 
on Pri.productNr = Pro.productNr
inner join Situation
on Situation.situationName = Pri.situationName
where Sale.saleNumber = 12
GROUP BY Sale.saleNumber


/*
Opgave 2c
*/
select PCP.title, PRO.productName, SUM(OL.amount) as 'Number Sold', S.endDate
from Product PRO
inner join ProductCategoryProduct PCP
on PRO.productNr = PCP.productNr
inner join Price as Pri
on Pri.productNr = PRO.productNr
inner join OrderLine OL
on OL.priceId = Pri.priceId
inner join Sale S
on OL.saleNumber = S.saleNumber
group by PCP.title, PRO.productName, S.endDate
having SUM(OL.amount) >= 5 AND MONTH(S.endDate) = 7


/*
Opgave 2d
*/
SELECT ProductCategory.title, Pro.productName from ProductCategory
inner join ProductCategoryProduct as ProCat
on ProCat.title = ProductCategory.title
inner join Product as Pro
on Pro.productNr = ProCat.productNr
inner join Price as Pri
on Pri.productNr = pro.productNr
inner join Situation as Sit
on sit.situationName = Pri.situationName
EXCEPT
SELECT ProductCategory.title, Pro.productName from ProductCategory
inner join ProductCategoryProduct as ProCat
on ProCat.title = ProductCategory.title
inner join Product as Pro
on Pro.productNr = ProCat.productNr
inner join Price as Pri
on Pri.productNr = pro.productNr
inner join Situation as Sit
on sit.situationName = Pri.situationName
WHERE sit.situationName = 'Fredagsbar'


/*
Opgave 2e
*/
SELECT AVG(asset_sums) as gennemsnit
FROM Sale
inner JOIN
(
SELECT sale.saleNumber, SUM(ISNULL(O.fixedPrice, Pri.priceValue * O.amount * (1.0 - Pri.percentDiscount /100.0))) AS asset_sums FROM Sale
Inner join OrderLine as O
on Sale.saleNumber = O.saleNumber
inner join Price as Pri
on Pri.priceId = O.priceId
inner join Situation
on Situation.situationName = Pri.situationName
group by Sale.saleNumber
) inner_query
on inner_query.saleNumber = Sale.saleNumber


/*
Opgave 2f
*/
select PCP.title, MAX(PRI.priceValue) as 'Max Price'
from ProductCategoryProduct PCP
inner join Product PR
on PCP.productNr = PR.productNr
inner join Price PRI
on PR.productNr = PRI.productNr
group by PCP.title


/*
Opgave 2g
*/
select pc.title, p.productName,pr.priceValue from ProductCategoryProduct pcp
inner join ProductCategory pc
on pcp.title = pc.title
inner join Price pr
on pr.productNr = pcp.productNr
inner join Product p
on p.productNr = pr.productNr
inner join
(select pcp.title, MAX(pr.priceValue) as MaxPris from ProductCategoryProduct pcp
inner join Price pr
on pr.productNr = pcp.productNr
GROUP BY PCp.title) MaxInCategory
on maxInCategory.title = pc.title
where MaxInCategory.MaxPris = pr.priceValue


/*
Opgave 3a
*/
GO
CREATE VIEW antalAfProduktersolgt
AS
SELECT ProductCategory.title, Product.productName, COUNT(OrderLine.saleNumber) as antal from ProductCategory
inner join ProductCategoryProduct as ProCatPro
on ProCatPro.title = productCategory.title
inner join Product
on Product.productNr = ProCatPro.productNr
inner join Price
on Price.productNr = Product.productNr
LEFT JOIN OrderLine
on OrderLine.priceId = Price.priceId
GROUP BY ProductCategory.title, Product.productName

SELECT * From antalAfProduktersolgt


/*
Opgave 3b
*/
GO;
CREATE VIEW SaleOverview 
AS
select S.saleNumber, C.personName as Customer, E.personName as Salesman, 
                            (SELECT SUM(ISNULL(O.fixedPrice, Pri.priceValue * (1.0-PRI.percentDiscount/100.0) * O.amount)) as total 
                            from Sale
                            Inner join OrderLine as O
                            on Sale.saleNumber = O.saleNumber
                            inner join Price as Pri
                            on Pri.priceId = O.priceId
                            where Sale.saleNumber = S.saleNumber
                            GROUP BY Sale.saleNumber
                            ) as SaleTotal
from Sale S
inner join Customer C
on C.customerId = S.customerId
inner join Employee E
on E.employeeId = S.employeeId

select Salesman, SUM(SaleTotal) as 'Total sold'
from SaleOverview
group by Salesman


/*
Opgave 4a
*/
go
Create PROC WritePriceList
@situationName VARCHAR(40)
AS
SELECT Product.productName, sum(priceValue * (1.0 + (percentDiscount/ 100.0))) as 'Pris' from Product
inner join Price as P
on P.productNr = Product.productNr
inner join Situation
on Situation.situationName = P.situationName
WHERE Situation.situationName = @situationName
Group by Product.productName

exec WritePriceList 'Fredagsbar'


/*
Opgave 4b
*/
go
CREATE PROCEDURE setDiscountOnProductCategory 
@percent Integer, 
@category varchar(40)
as
Update Price
set percentDiscount = @percent
where Price.productNr in (select PCP.productNr from ProductCategoryProduct PCP where PCP.title = @category)

Exec setDiscountOnProductCategory 10, 'Flaskeøl'


/* 
Opgave 4c
*/
go
Create proc FindPersonMedNavn
@personName varchar(30)
as
Begin
Select e.personName, e.phoneNumber
from Employee e
where e.personName like @personName + '%'
Union all
select c.personName, c.phoneNumber
from Customer c
where c.personName like @personName + '%'
End

exec FindPersonMedNavn 'Peter'

drop proc FindPersonMedNavn


/*
Opgave 5a
*/
-- Testdata til opgave 5a
Insert into Product VALUES('Hat', 30,10,'')
insert into ProductCategory Values('Sjove hatte','Alle mulige sjove hatte')
Insert into Product VALUES('Hatter', 30,10,'')
INSERT into ProductCategoryProduct values('Sjove hatte', 86)
INSERT into ProductCategoryProduct values('Sjove hatte', 87)
INSERT into ProductCategoryProduct values('Sjove hatte', 88)
INSERT into ProductCategoryProduct values('Sjove hatte', 89)
-----------------------------------------------------------------------------
go
Create trigger sletTomProduktKategori
       on product
       instead of delete
       as
       declare @produktetsProduktgruppe as varchar(40)
       declare @produktNr as integer
       set @produktNr = (select productNr from deleted)
       set @produktetsProduktgruppe = (select title from ProductCategoryProduct where productNr = @produktNr)
       delete from ProductCategoryProduct
       where ProductCategoryProduct.productNr = @produktNr
       delete from Product
       where Product.productNr = @produktNr
IF not exists (select title from ProductCategoryProduct where title = @produktetsProduktgruppe)
       begin
       delete from ProductCategory
       where ProductCategory.title = @produktetsProduktgruppe
       print 'produktet og produktgruppen blev slettet'
       end
else
       begin
       print 'Produktet blev slettet'
       end

Drop TRIGGER sletTomProduktKategori

SELECT * From Product

DELETE From Product
where productNr = 89


/*
Opgave 5b
*/
-- Testdata til opgave 5b
INSERT INTO Product VALUES('MOKAI', 30, 10, 'Lidt sjov')
SELECT * FROM Product
INSERT into Price VALUES(10,0,90,'Standard')
SELECT * FRom Price
INSERT into OrderLine Values(5,null,1,53)
-----------------------------------------------------------------------------
GO
CREATE TRIGGER OpdatereAntal on orderline
after INSERT
AS
DECLARE @productNr as INT
set @productNr = (Select Product.productNr from inserted
Inner join Price
On Price.priceId = inserted.priceId
inner join Product
on Product.productNr = Price.productNr)
DECLARE @amount as INT
set @amount = (select amount from inserted)
BEGIN
UPDATE Product
set currentAmount = currentAmount - @amount
WHERE productNr = @productNr
END

drop TRIGGER OpdatereAntal
