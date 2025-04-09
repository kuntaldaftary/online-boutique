resource "aws_elasticache_cluster" "redis_cart" {
  cluster_id           = "redis-cart"
  engine               = "redis"
  node_type            = "cache.t3.micro"  # Free Tier eligible
  num_cache_nodes      = 1
  parameter_group_name = "default.redis6.x"
  subnet_group_name    = aws_elasticache_subnet_group.redis_subnet_group.id
}

resource "aws_elasticache_subnet_group" "redis_subnet_group" {
  name       = "redis-subnet-group"
  subnet_ids = [aws_subnet.private.id]
}
