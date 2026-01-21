create database hackthong_2;
use hackthong_2;

create table customers (
    customer_id varchar(10) primary key,
    full_name varchar(100) not null,
    phone_number varchar(10) not null unique,
    email varchar(255) not null,
    join_date datetime default current_timestamp
);

create table insurance_packages (
    package_id varchar(10) primary key,
    package_name varchar(100) not null,
    max_limit decimal(15,2) not null check (max_limit > 0),
    base_premium decimal(15,2) not null
);

create table policies (
    policy_id varchar(10) primary key,
    customer_id varchar(10) not null,
    package_id varchar(10) not null,
    start_date date not null,
    end_date date not null,
    status enum ('Active', 'Expired', 'Cancelled'),
    foreign key (customer_id) references customers(customer_id),
    foreign key (package_id) references insurance_packages(package_id)
);

create table claims (
    claim_id varchar(10) primary key,
    policy_id varchar(10) not null,
    claim_date date not null,
    claim_amount decimal(15,2) not null check (claim_amount > 0),
    status enum ('Pending', 'Approved', 'Rejected'),
    foreign key (policy_id) references policies(policy_id)
);

create table claim_processing_log (
    log_id varchar(20) primary key,
    claim_id varchar(10),
    action_detail varchar(255),
    recorded_at datetime not null,
    processor varchar(100) not null,
    foreign key (claim_id) references claims(claim_id)
);


insert into customers values
('C001','Nguyen Hoang Long','0901112223','long.nh@gmail.com','2024-01-15'),
('C002','Tran Thi Kim Anh','0988877766','anh.tk@yahoo.com','2024-03-10'),
('C003','Le Hoang Nam','0903334445','nam.lh@outlook.com','2025-05-20'),
('C004','Pham Minh Duc','0355556667','duc.pm@gmail.com','2025-08-12'),
('C005','Hoang Thu Thao','0779998881','thao.ht@gmail.com','2026-01-01');

insert into insurance_packages values
('PKG01','Bao hiem suc khoe gold',500000000,5000000),
('PKG02','Bao hiem o to liberty',1000000000,15000000),
('PKG03','Bao hiem nhan tho an binh',2000000000,25000000),
('PKG04','Bao hiem du lich quoc te',100000000,1000000),
('PKG05','Bao hiem tai nan 24/7',200000000,2500000);

insert into policies values
('POL101','C001','PKG01','2024-01-15','2025-01-15','Expired'),
('POL102','C002','PKG02','2024-03-10','2026-03-10','Active'),
('POL103','C003','PKG03','2025-05-20','2035-05-20','Active'),
('POL104','C004','PKG04','2025-08-12','2025-09-12','Expired'),
('POL105','C005','PKG01','2026-01-01','2027-01-01','Active');

insert into claims values
('CLM901','POL102','2024-06-15',12000000,'Approved'),
('CLM902','POL103','2025-10-20',50000000,'Pending'),
('CLM903','POL101','2024-11-05',5500000,'Approved'),
('CLM904','POL105','2026-01-15',2000000,'Rejected'),
('CLM905','POL102','2025-02-10',120000000,'Approved');

insert into claim_processing_log values
('L001','CLM901','Da nhan ho so hien truong','2024-06-15 09:00','Admin_01'),
('L002','CLM901','Chap nhan boi thuong','2024-06-20 14:30','Admin_01'),
('L003','CLM902','Dang tham dinh ho so','2025-10-21 10:00','Admin_02'),
('L004','CLM904','Tu choi boi thuong','2026-01-16 16:00','Admin_03'),
('L005','CLM905','Da thanh toan chuyen khoan','2025-02-15 08:30','Admin_01');


-- Viết câu lệnh tăng phí bảo hiểm cơ bản thêm 15% cho các gói bảo hiểm có hạn mức chi trả trên 500.000.000 VNĐ.
update insurance_packages
set base_premium = base_premium * 1.15
where max_limit > 500000000;

-- Viết câu lệnh xóa các nhật ký xử lý bồi thường (Claim_Processing_Log) được ghi nhận trước ngày 20/6/2025.
delete from claim_processing_log
where recorded_at < '2025-06-20';

-- PHẦN 2: TRUY VẤN DỮ LIỆU CƠ BẢN
-- Câu 1: Liệt kê thông tin các hợp đồng có trạng thái 'Active' và có ngày kết thúc trong năm 2026.
select *
from policies
where status = 'Active'
  and year(end_date) = 2026;

-- Câu 2: Lấy thông tin khách hàng (Họ tên, Email) có tên chứa chữ 'Hoàng' và tham gia bảo hiểm từ năm 2025 trở lại đây.
select full_name, email
from customers
where full_name like '%Hoang%'
  and join_date >= '2025-01-01';

-- Câu 3: Hiển thị top 3 yêu cầu bồi thường (Claims) có số tiền được yêu cầu cao nhất, bỏ qua yêu cầu cao nhất (lấy từ vị trí số 2 đến số 4).
select *
from claims
order by claim_amount desc
limit 3 offset 1;

-- PHẦN 3: TRUY VẤN DỮ LIỆU NÂNG CAO

-- Câu 1: Sử dụng JOIN để hiển thị: Tên khách hàng, Tên gói bảo hiểm, Ngày bắt đầu hợp đồng và Số tiền bồi thường (nếu có).
select 
    cu.full_name,
    ip.package_name,
    po.start_date,
    cl.claim_amount
from customers cu
join policies po on cu.customer_id = po.customer_id
join insurance_packages ip on po.package_id = ip.package_id
left join claims cl on po.policy_id = cl.policy_id;

-- Câu 2: Thống kê tổng số tiền bồi thường đã chi trả ('Approved') cho từng khách hàng. Chỉ hiện những người có tổng chi trả > 50.000.000 VNĐ.
select cu.full_name, sum(cl.claim_amount) as total_paid
from customers cu
join policies po on cu.customer_id = po.customer_id
join claims cl on po.policy_id = cl.policy_id
where cl.status = 'Approved'
group by cu.customer_id, cu.full_name
having total_paid > 50000000;

-- Câu 3: Tìm gói bảo hiểm có số lượng khách hàng đăng ký nhiều nhất.
select ip.package_name, count(*) as total_customers
from policies po
join insurance_packages ip on po.package_id = ip.package_id
group by ip.package_id
order by total_customers desc
limit 1;


-- PHẦN 4: INDEX VÀ VIEW
-- Câu 1: Tạo Composite Index tên idx_policy_status_date trên bảng Policies cho hai cột: status và start_date.
create index idx_policy_status_date
on policies(status, start_date);

-- Câu 2: Tạo một View tên vw_customer_summary hiển thị: Tên khách hàng, Số lượng hợp đồng đang sở hữu, và Tổng phí 
create view vw_customer_summary as
select 
    c.full_name,
    count(p.policy_id) as total_policies,
    sum(ip.base_premium) as total_premium
from customers c
left join policies p on c.customer_id = p.customer_id
left join insurance_packages ip on p.package_id = ip.package_id
group by c.customer_id, c.full_name;

-- PHẦN 5: TRIGGER
-- Câu 1: Viết Trigger trg_after_claim_approved. Khi một yêu cầu bồi thường chuyển trạng thái sang 'Approved', tự động thêm một dòng vào Claim_Processing_Log với nội dung 'Payment processed to customer'.
delimiter $$

create trigger trg_after_claim_approved
after update on claims
for each row
begin
    if old.status <> 'Approved' and new.status = 'Approved' then
        insert into claim_processing_log
        values (
            concat('LOG', unix_timestamp()),
            new.claim_id,
            'Payment processed to customer',
            now(),
            'System'
        );
    end if;
end$$

-- Câu 2: Viết Trigger ngăn chặn việc xóa hợp đồng nếu trạng thái của hợp đồng đó đang là 'Active'.
create trigger trg_prevent_delete_active_policy
before delete on policies
for each row
begin
    if old.status = 'Active' then
        signal sqlstate '45000'
        set message_text = 'Cannot delete active policy';
    end if;
end$$

delimiter ;

-- fix time
