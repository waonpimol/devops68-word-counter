## 1. Clone โปรเจกต์จาก GitHub

เริ่มจาก clone โปรเจกต์มาก่อน

```
git clone https://github.com/waonpimol/devops68-word-counter.git
cd devops68-word-counter
```

## 2. ตั้งค่า AWS

ตั้งค่า AWS credentials ด้วยคำสั่ง

```
aws configure
```

จากนั้นใส่

* AWS Access Key
* AWS Secret Key
* Region (เช่น ap-southeast-1)

## 3. เริ่มต้น Terraform

รันคำสั่งนี้เพื่อให้ Terraform โหลด provider

```
terraform init
```

## 4. ตรวจสอบสิ่งที่จะถูกสร้าง

```
terraform plan
```

## 5. สร้าง Infrastructure

```
terraform apply
```

พิมพ์

```
yes
```

Terraform จะสร้าง EC2 และ deploy แอปให้อัตโนมัติ

## 6. ทดสอบ API

ใช้ Public IP ของ EC2

```
http://PUBLIC_IP:3008/count?text=hello world
```

ถ้าใช้งานได้จะได้ผลลัพธ์ประมาณนี้

```
{
  "text": "hello world",
  "words": 2,
  "characters": 11,
  "charactersNoSpace": 10
}
```
