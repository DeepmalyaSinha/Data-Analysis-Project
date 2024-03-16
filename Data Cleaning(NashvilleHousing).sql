
select * from PortfolioProject..nashvillehousing
order by ParcelID 

--Standardizing date 
-- checking
select saledate, convert(date,saledate)
from PortfolioProject..nashvillehousing
--implementing
alter table portfolioproject..nashvillehousing
alter column saledate date

-- populate property address data

select propertyaddress from PortfolioProject..nashvillehousing

select a.ParcelID,b.ParcelID,a.PropertyAddress,b.PropertyAddress,isnull(a.PropertyAddress,b.PropertyAddress) from portfolioproject..nashvillehousing a join
portfolioproject..nashvillehousing b on
a.parcelid=b.parcelid and
a.[UniqueID ] <> b.[UniqueID ]
where a.propertyaddress is null

update a
set PropertyAddress=isnull(a.PropertyAddress,b.PropertyAddress)
from portfolioproject..nashvillehousing a join
portfolioproject..nashvillehousing b on
a.parcelid=b.parcelid and
a.[UniqueID ] <> b.[UniqueID ]
where a.propertyaddress is null

--breaking out address into individual columns

--using substring

select SUBSTRING(propertyaddress,1,charindex(',',PropertyAddress)-1) as address,
SUBSTRING(propertyaddress,charindex(',',PropertyAddress)+1,len(propertyaddress))as address
from portfolioproject..nashvillehousing

alter table portfolioproject..nashvillehousing
add propertysplitaddress nvarchar(255), propertysplitcity nvarchar(255);

update PortfolioProject..nashvillehousing
set propertysplitaddress=SUBSTRING(propertyaddress,1,charindex(',',PropertyAddress)-1),
propertysplitcity =SUBSTRING(propertyaddress,charindex(',',PropertyAddress)+1,len(propertyaddress))

alter table PortfolioProject..nashvillehousing
drop column propertyaddress

select 
parsename(replace(owneraddress,',','.'),3),
parsename(replace(owneraddress,',','.'),2),
parsename(replace(owneraddress,',','.'),1)
from PortfolioProject..nashvillehousing
where OwnerAddress is not null

alter table portfolioproject..nashvillehousing
add ownersplitaddress nvarchar(255), ownersplitcity nvarchar(255),ownersplitstate nvarchar(255);

update PortfolioProject..nashvillehousing
set ownersplitaddress=parsename(replace(owneraddress,',','.'),3),
ownersplitcity=parsename(replace(owneraddress,',','.'),2),
ownersplitstate=parsename(replace(owneraddress,',','.'),1)

alter table PortfolioProject..nashvillehousing
drop column owneraddress

--changing irregularities in soldasvacant

select distinct(soldasvacant),count(soldasvacant)
from PortfolioProject..nashvillehousing
group by SoldAsVacant

select soldasvacant,
case when soldasvacant='Y' then 'Yes'
     when soldasvacant='N' then 'No'
	 else SoldAsVacant
end
from PortfolioProject..nashvillehousing

update PortfolioProject..nashvillehousing
set SoldAsVacant=case when soldasvacant='Y' then 'Yes'
     when soldasvacant='N' then 'No'
	 else SoldAsVacant
	 end

-- removing duplicates
with rownumcte as(
select *,row_number() over ( partition by parcelid, propertyaddress,saledate,saleprice,legalreference order by uniqueid ) rownum
from PortfolioProject.dbo.nashvillehousing
)

delete 
from rownumcte
where rownum>1