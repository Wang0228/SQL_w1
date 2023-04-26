-- ��X�M�̶Q�����~�P���O���Ҧ����~

select *
from Products
where CategoryID=(
select top 1 CategoryID
from Products
order by UnitPrice desc
)

-- ��X�M�̶Q�����~�P���O�̫K�y�����~

select top 1 *
from Products
where CategoryID=(
select top 1 CategoryID
from Products
order by UnitPrice desc
)
order by UnitPrice

-- �p��X�W�����O�̶Q�M�̫K�y����Ӳ��~�����t

select max(UnitPrice)-min(UnitPrice)
from Products
where CategoryID=(
select top 1 CategoryID
from Products
order by UnitPrice desc
)

-- ��X�S���q�L����ӫ~���Ȥ�Ҧb���������Ҧ��Ȥ�

select *
from Customers
where City in (
select c.City
from Customers c
left join Orders o on o.CustomerID=c.CustomerID
where o.OrderID is null)


-- ��X�� 5 �Q��� 8 �K�y�����~�����~���O

select *
from(select *,ROW_NUMBER() over (order by UnitPrice desc) as number from Products)t
inner join Categories c on c.CategoryID=t.CategoryID
where number=5 or number=(select COUNT(*) from Products)-7


-- ��X�ֶR�L�� 5 �Q��� 8 �K�y�����~

select distinct o.CustomerID
from Orders o
join [Order Details] od on od.OrderID=o.OrderID
join Products p on p.ProductID=od.ProductID
join Categories c on c.CategoryID=p.CategoryID
join Customers ct on ct.CustomerID=o.CustomerID
where p.ProductName in(
select ProductName
from (select *,ROW_NUMBER() over (order by UnitPrice desc) as number from Products)t
inner join Categories c on c.CategoryID=t.CategoryID
where t.number=5 or t.number=(select COUNT(*) from Products)-7
)


-- ��X�ֽ�L�� 5 �Q��� 8 �K�y�����~

select distinct SupplierID,CompanyName
from Orders o
join [Order Details] od on od.OrderID=o.OrderID
join Products p on p.ProductID=od.ProductID
join Categories c on c.CategoryID=p.CategoryID
join Customers ct on ct.CustomerID=o.CustomerID
where p.ProductName in(
select ProductName
from (select *,ROW_NUMBER() over (order by UnitPrice desc) as number from Products)t
inner join Categories c on c.CategoryID=t.CategoryID
where t.number=5 or t.number=(select COUNT(*) from Products)-7
)

-- ��X 13 ���P�������q�� (�c�]���q��)

select *
from Orders
where DATEPART(WEEKDAY,OrderDate)=6 and DATEPART(DAY,OrderDate)=13

-- ��X�֭q�F�c�]���q��

select o.CustomerID,c.ContactName
from Orders o
inner join Customers c on c.CustomerID=o.CustomerID
where DATEPART(WEEKDAY,OrderDate)=6 and DATEPART(DAY,OrderDate)=13


-- ��X�c�]���q��̦����򲣫~

select o.OrderDate,p.ProductID,p.ProductName
from Orders o
inner join [Order Details] od on od.OrderID=o.OrderID
inner join Products p on p.ProductID=od.ProductID
where DATEPART(WEEKDAY,OrderDate)=6 and DATEPART(DAY,OrderDate)=13

-- �C�X�q�ӨS������ (Discount) �X�⪺���~

select *
from [Order Details] o
inner join Products p on p.ProductID=o.ProductID
where o.Discount=0

-- �C�X�ʶR�D���ꪺ���~���Ȥ�

select distinct c.CustomerID
from Orders o
inner join Customers c on c.CustomerID=o.CustomerID
inner join [Order Details] od on od.OrderID=o.OrderID
inner join Products p on p.ProductID=od.ProductID
inner join Suppliers s on s.SupplierID=p.SupplierID
where s.Country!=c.Country

-- �C�X�b�P�ӫ����������q���u�i�H�A�Ȫ��Ȥ�

select distinct c.CustomerID,c.ContactName
from Orders o
inner join Customers c on c.CustomerID=o.CustomerID
inner join Employees e on e.EmployeeID=o.EmployeeID
where e.City=c.City

-- �C�X���ǲ��~�S���H�R�L

select *
from Products p
left join [Order Details] od on od.ProductID=p.ProductID
where p.ProductID is null

----------------------------------------------------------------------------------------

-- �C�X�Ҧ��b�C�Ӥ�멳���q��

select *
from Orders
where OrderDate=EOMONTH(OrderDate)

-- �C�X�C�Ӥ�멳��X�����~

select p.*,o.OrderDate
from Products p
inner join [Order Details] od on od.ProductID=p.ProductID
inner join Orders o on o.OrderID=od.OrderID
where o.OrderDate in(
select OrderDate
from Orders
where OrderDate=EOMONTH(OrderDate)
)

-- ��X���ѹL�̶Q���T�Ӳ��~��������@�Ӫ��e�T�Ӥj�Ȥ�
select top 3 c.CustomerID,(
select sum(od.UnitPrice*od.Quantity*(1-od.Discount))
) as total
from Orders o
inner join [Order Details] od on od.OrderID=o.OrderID
inner join Customers c on c.CustomerID=o.CustomerID
where od.ProductID in(
select top 3 ProductID
from Products
order by UnitPrice desc
)
group by c.CustomerID
order by total desc


-- ��X���ѹL�P����B�e�T���Ӳ��~���e�T�Ӥj�Ȥ�

select top 3 c.CustomerID,sum(od.UnitPrice*od.Quantity*(1-od.Discount)) as total
from Customers c
inner join Orders o on o.CustomerID=c.CustomerID
inner join [Order Details] od on od.OrderID=o.OrderID
inner join Products p on p.ProductID=od.ProductID
where p.ProductID in (
select top 3 p.ProductID
from [Order Details] od
inner join Products p on p.ProductID=od.ProductID
inner join Orders o on o.OrderID=od.OrderID
group by p.ProductID
order by sum(od.UnitPrice*od.Quantity*(1-od.Discount))desc)
group by c.CustomerID
order by total desc

-- ��X���ѹL�P����B�e�T���Ӳ��~�������O���e�T�Ӥj�Ȥ� 

with t1 as(select top 3 p.ProductID,p.CategoryID
from [Order Details] od 
left join Products p on p.ProductID=od.ProductID
group by p.ProductID,p.CategoryID
order by sum(od.UnitPrice*od.Quantity*(1-od.Discount)) desc)
select top 3 o.CustomerID
from Products p
left join [Order Details] od on od.ProductID=p.ProductID
left join Orders o on o.OrderID=od.OrderID
where p.CategoryID in (
select CategoryID
from t1
)
group by o.CustomerID
order by sum(od.UnitPrice*od.Quantity*(1-od.Discount))desc


-- �C�X���O�`���B����Ҧ��Ȥᥭ�����O�`���B���Ȥ᪺�W�r�A�H�ΫȤ᪺���O�`���B

select c.CustomerID,sum(od.UnitPrice*od.Quantity*(1-od.Discount)) as total
from Customers c
inner join Orders o on o.CustomerID=c.CustomerID
inner join [Order Details] od on od.OrderID=o.OrderID
group by c.CustomerID
HAVING sum(od.UnitPrice*od.Quantity*(1-od.Discount))>(select AVG(od.UnitPrice*od.Quantity*(1-od.Discount)) from [Order Details] od inner join Orders o on o.OrderID=od.OrderID)

-- �C�X�̼��P�����~�A�H�γQ�ʶR���`���B

select ProductID,sum(UnitPrice*Quantity*(1-Discount))as total
from [Order Details]
where ProductID=(
select top 1 p.ProductID
from Products p
inner join [Order Details] od on od.ProductID=p.ProductID
group by p.ProductID
order by sum(od.Quantity) desc
)
group by ProductID

-- �C�X�̤֤H�R�����~

select top 1 p.ProductID,p.ProductName,sum(od.Quantity) as sell
from [Order Details] od
inner join Products p on p.ProductID=od.ProductID
group by p.ProductID,p.ProductName
order by sell

-- �C�X�̨S�H�n�R�����~���O (Categories)

select top 1 c.CategoryID,sum(od.Quantity)as sell
from Categories c
inner join Products p on p.CategoryID=c.CategoryID
inner join [Order Details] od on od.ProductID=p.ProductID
group by c.CategoryID
order by sell

-- �C�X��P��̦n�������ӶR�̦h���B���Ȥ�P�ʶR���B (�t�ʶR�䥦�����Ӫ����~)

select c.CustomerID, sum(od.UnitPrice*od.Quantity*(1-od.Discount))as total
from Customers c
inner join Orders o on o.CustomerID=c.CustomerID
inner join [Order Details] od on od.OrderID=o.OrderID
where c.CustomerID in (
select top 1 c.CustomerID
from Customers c
inner join Orders o on o.CustomerID=c.CustomerID
inner join [Order Details] od on od.OrderID=o.OrderID
inner join Products	p on p.ProductID=od.ProductID
inner join Suppliers s on s.SupplierID=p.SupplierID
where s.SupplierID=(
select top 1 s.SupplierID
from Suppliers s
inner join Products p on p.SupplierID=s.SupplierID
inner join [Order Details] od on od.ProductID=p.ProductID
group by s.SupplierID
order by sum(od.Quantity)
)
group by c.CustomerID
order by (
select sum(od.UnitPrice*od.Quantity*(1-od.Discount)) as total
from Customers cu
inner join Orders o on o.CustomerID=cu.CustomerID
inner join [Order Details] od on od.OrderID=o.OrderID
where cu.CustomerID=c.CustomerID
group by cu.CustomerID
) desc
)
group by c.CustomerID

-- �C�X��P��̦n�������ӶR�̦h���B���Ȥ�P�ʶR���B (���t�ʶR�䥦�����Ӫ����~)

select top 1 o.CustomerID, sum(od.UnitPrice*od.Quantity*(1-od.Discount)) as price
from Products p
inner join [Order Details] od on od.ProductID=p.ProductID
inner join Orders o on o.OrderID=od.OrderID
where p.SupplierID=(select top 1 s.SupplierID
from Suppliers s
left join Products p on p.SupplierID=s.SupplierID
left join [Order Details] od on od.ProductID=p.ProductID
group by s.SupplierID
order by sum(od.UnitPrice*od.Quantity*(1-od.Discount)) desc)
group by o.CustomerID
order by  price desc

-- �C�X���ǲ��~�S���H�R�L

select *
from Products p
left join [Order Details] od on od.ProductID=p.ProductID
where od.Quantity is null

-- �C�X�S���ǯu (Fax) ���Ȥ�M�������O�`���B

select c.CustomerID,sum(od.UnitPrice*od.Quantity*(1-od.Discount)) as total
from Customers c
inner join Orders o on o.CustomerID=c.CustomerID
inner join [Order Details] od on o.OrderID=od.OrderID
where c.Fax is null
group by c.CustomerID

-- �C�X�C�@�ӫ������O�����~�����ƶq

select t.City,count(t.CategoryID)as num
from(
select distinct c.City,p.CategoryID
from Customers c
inner join Orders o on o.CustomerID=c.CustomerID
inner join [Order Details] od on od.OrderID=o.OrderID
inner join Products p on p.ProductID=od.ProductID
) t
group by t.City

-- �C�X�ثe�S���w�s�����~�b�L�h�`�@�Q�q�ʪ��ƶq

select sum(od.Quantity) as num
from Products p
left join [Order Details] od on od.ProductID=p.ProductID
where p.UnitsInStock='0'

-- �C�X�ثe�S���w�s�����~�b�L�h���g�Q���ǫȤ�q�ʹL

select distinct o.CustomerID
from Products p
inner join [Order Details] od on od.ProductID=p.ProductID
inner join Orders o on o.OrderID=od.OrderID
where p.UnitsInStock='0'

-- �C�X�C����u���U�ݪ��~�Z�`���B

select (e.FirstName+e.LastName) as name , sum(od.UnitPrice*od.Quantity*(1-od.Discount)) as total
from Employees e
inner join Orders o on o.EmployeeID=e.EmployeeID
inner join [Order Details] od on od.OrderID=o.OrderID
group by (e.FirstName+e.LastName)



-- �C�X�C�a�f�B���q�B�e�̦h�����@�ز��~���O�P�`�ƶq

with t1 as(select s.CompanyName,p.CategoryID,count(p.CategoryID)as a
from Shippers s
inner join Orders o on o.ShipVia=s.ShipperID
inner join [Order Details] od on od.OrderID=o.OrderID
inner join Products p on p.ProductID=od.ProductID
group by s.CompanyName,p.CategoryID),
t2 as(select *,
rank() over (partition by CompanyName order by a desc) as r
from t1 )
select * 
from t2
where r=1


-- �C�X�C�@�ӫȤ�R�̦h�����~���O�P���B

with t1 as(
select c.CustomerID,p.CategoryID,sum(od.Quantity) as Qty,sum(od.UnitPrice*od.Quantity*(1-od.Discount))as price
from Customers c
inner join Orders o on o.CustomerID=c.CustomerID
inner join [Order Details] od on od.OrderID=o.OrderID
inner join Products p on p.ProductID=od.ProductID
group by c.CustomerID,p.CategoryID
),
t2 as(
select *,rank() over(partition by CustomerID order by Qty desc)as rk
from t1)
select CustomerID,CategoryID,price
from t2
where rk=1

-- �C�X�C�@�ӫȤ�R�̦h�����@�Ӳ��~�P�ʶR�ƶq

with t1 as(select o.CustomerID,od.ProductID,sum(od.Quantity)as q
from Orders o
inner join [Order Details] od on od.OrderID=o.OrderID
group by o.CustomerID,od.ProductID),
t2 as(
select *,rank() over (partition by CustomerID order by q desc) as qu
from t1)
select CustomerID,ProductID,q
from t2
where qu=1

-- ���ӫ��������A��X�C�@�ӫ����̪�@���q�檺�e�f�ɶ�

select ShipCity,MAX(ShippedDate)
from Orders
where ShipCity is not null
group by ShipCity

-- �C�X�ʶR���B�Ĥ��W�P�ĤQ�W���Ȥ�A�H�Ψ�ӫȤ᪺���B�t�Z

with t1 as(
select o.CustomerID,sum(od.UnitPrice*od.Quantity*(1-od.Discount))as rk
from Orders o
inner join [Order Details] od on od.OrderID=o.OrderID
group by o.CustomerID
),
t2 as(select *
from t1
where CustomerID in(select CustomerID
from t1
order by rk desc
offset 4 rows 
fetch next 1 rows only
union all
select CustomerID
from t1
order by rk desc
offset 9 rows 
fetch next 1 rows only))
select *,(lag(rk) over (order by rk desc)-rk)as diff
from t2