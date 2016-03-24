import csfml, mersenne, math, sequtils, lists, particle, life, physics, util

type
  Emitter* = ref object of RootObj
    pool*:         ParticlePool
    physics*:      Physics
    twister:       MersenneTwister
    speed*:        Property
    rotation*:     Property
    size*:         Property
    color*:        Property
    alpha*:        Property
    ttl*:          Property
    maxParticles*: int  
    curParticles:  int
    particles*:    seq[Particle]
    texture*:      Texture
    life*:         Life

proc draw*(emitter: Emitter, render: RenderWindow) =
  for particle in emitter.particles:
    particle.draw render

proc update*(emitter: Emitter) =
  
  if emitter.life != nil:
    emitter.life.update

  emitter.physics.update

  for i, particle in emitter.particles:
    particle.update

    if particle.life.IsAlive != true:
      emitter.pool.ret(particle)
      emitter.particles.delete(i)
      dec(emitter.curParticles)

  if emitter.curParticles < emitter.maxParticles:
    for i in 1..min(50, emitter.maxParticles - emitter.curParticles):
      let
        speed:    float    = emitter.speed.get[0]
        ttl:      int      = int(emitter.ttl.get[0])
        rotation: float    = emitter.rotation.get[0]
        size:     float    = emitter.size.get[0]
        
        particle: Particle = emitter.pool.borrow(
          emitter.physics.location.x, 
          emitter.physics.location.y, 
          color(255,255,255,0),  
          ttl, 
          speed, 
          rotation, size
        )
      
      if particle != nil:
        emitter.particles.add(particle)
        inc(emitter.curParticles)

proc clear*(emitter: Emitter) =
  for i, particle in emitter.particles:
    emitter.pool.ret(particle)
    emitter.particles.delete(i)
    dec(emitter.curParticles)

proc len*(emitter: Emitter): int =
  emitter.particles.len

proc newEmitter*(
  pool:         ParticlePool,  
  x:            float,
  y:            float,
  speed:        Property,
  rotation:     Property,
  size:         Property,
  color:        Property,
  alpha:        Property,
  ttl:          Property,
  maxParticles: int,
  life:         Life = nil,
  twister: MersenneTwister
): Emitter =

  result = new(Emitter)

  result.twister      = twister
  result.physics      = newPhysics(x, y)
  result.maxParticles = maxParticles
  result.curParticles = 0
  result.particles    = @[]
  result.pool         = pool
  result.speed        = speed
  result.rotation     = rotation
  result.size         = size
  result.color        = color
  result.alpha        = alpha
  result.ttl          = ttl
  result.life         = life