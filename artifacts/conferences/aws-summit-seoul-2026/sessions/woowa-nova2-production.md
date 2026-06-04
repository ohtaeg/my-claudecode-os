---
title: 우아한형제들의 Nova 2 프로덕션 적용 여정
speaker: 김정곤 (AWS), 오윤택 (우아한형제들)
url: https://www.youtube.com/watch?v=u8EZ5QMk8Fc
conference: AWS Summit Seoul 2026
date: 2025-08-14
tags: [Aurora, DocumentDB, ElastiCache, Valkey, Graviton, IO-Optimized, Blue/Green Deployment, AWS Tags, DBA Automation, Cost Optimization]
---

> **[매핑 노트]** 이 노트는 AWS Summit Seoul 2026 **S116** 슬롯에 강제 매핑된 사례입니다.
> 영상 실제 내용은 "우아한형제들이 공유하는 1000여 대의 데이터베이스서비스 우아하게 운영하기"(김정곤·오윤택, 2025-08-14 업로드)이며, S116 마킹 제목("Nova 2 프로덕션 적용 여정", 장재주)과 다릅니다. OS 회고 박제 대상 (Day 7 채집).

## TL;DR
우아한형제들이 1,000여 대 DB를 운영하며 발견한 비용·운영 효율화 사례. DocumentDB 전환·Valkey 마이그레이션·Graviton 워크로드별 분리·IO-Optimized·Blue/Green을 조합해 2022년부터 매년 약 30% 비용 절감과 새벽작업 50% 감소를 달성.

## 핵심 인사이트
- 조직개편이 매월 일어나는 환경에서 DB 담당자 매핑이 무너지는 문제를 AWS 태그 기반 메타데이터로 해결 — 라이트사이징 알람을 누구에게 보낼지 식별하는 핵심 장치로 활용
- MongoDB → DocumentDB 마이그레이션은 기술적 이유가 아닌 "명확한 비용 절감 목적"으로 결정. 공유 스토리지 구조 덕에 노드 3개 × 4TB EBS 같은 과다 구성 불필요, 실 사용량 과금으로 약 30% 비용 절감
- Graviton 전환 기준을 워크로드 크기로 명확히 분리: 2xlarge 이하는 Graviton2, 4xlarge 이상은 Graviton3. ElastiCache는 Intel/Graviton 성능 차이가 없고 G2와 G3도 차이가 없어 가장 싼 Graviton2 고정
- Aurora IO-Optimized는 IO 비용이 전체의 25% 넘는 클러스터에 한해 자동 선별·적용. 레이턴시도 약 2배 개선되며 대량 마이그레이션 시 필수 옵션
- Redis → Valkey 전환은 "엔진만 바꿨을 뿐"으로 비용 최대 20% 절감, 성능 5% 이상 향상, Set/Hash 사용 시 메모리 최대 30% 감소. 2026년 2월부터 전사 Redis를 모두 Valkey로 교체 완료
- 사내 자동화 툴 "스마트 DBA"로 DBA는 리뷰·승인만 수행, 새벽 수동 작업의 절반 이상을 자동 실행으로 대체 → 작업 생산성 2배 향상
- 알람은 "많이 받기"가 아닌 "정확히 받기"로 방향 전환. CPU·HLL 알람에 원인 메트릭(슬로쿼리, 트랜잭션 내용)을 메시지에 함께 담고, 단순 조회 쿼리로 인한 롱트랜잭션은 자동 kill까지 수행
- 1TB급 대용량 단일 테이블의 DDL·인덱스 작업(4시간+ 소요, 리소스 20~30% 증가)은 Blue/Green으로 처리 — DB 업그레이드 용도를 넘어 파티션 분리·과거 데이터 정리 등 무거운 작업 전반에 확대 적용
- 인프라 변경 시 애플리케이션이 페일오버·신규 리플리카를 즉시 인지하는 "유연성"이 비용 절감의 전제조건. 라이트사이징보다 변화 대응 구조 설계가 우선

## 태그
Aurora, DocumentDB, ElastiCache, Valkey, Graviton, IO-Optimized, Blue/Green Deployment, AWS Tags, DBA Automation, Cost Optimization
