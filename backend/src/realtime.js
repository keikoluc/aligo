const { Server } = require('socket.io');

const db = require('./db');
const { verifyToken } = require('./services/tokenService');

let io;

// A client only joins a listing's room after we confirm they're either
// its shipper or its assigned driver, so tracking data never leaks to
// an unrelated user who guesses a listing id.
async function canAccessListing(userId, listingId) {
  const listing = await db.get(
    'SELECT shipper_id, driver_id FROM cargo_listings WHERE id = ?',
    [listingId]
  );
  return !!listing && (listing.shipper_id === userId || listing.driver_id === userId);
}

function initRealtime(httpServer) {
  io = new Server(httpServer, { cors: { origin: '*' } });

  io.use((socket, next) => {
    try {
      socket.userId = verifyToken(socket.handshake.auth?.token).sub;
      next();
    } catch {
      next(new Error('Unauthorized'));
    }
  });

  io.on('connection', (socket) => {
    socket.on('join-listing', async (listingId, ack) => {
      const id = Number(listingId);
      if (!Number.isInteger(id) || !(await canAccessListing(socket.userId, id))) {
        return ack?.({ ok: false });
      }
      socket.join(`listing:${id}`);
      ack?.({ ok: true });
    });

    socket.on('leave-listing', (listingId) => {
      const id = Number(listingId);
      if (Number.isInteger(id)) socket.leave(`listing:${id}`);
    });
  });

  return io;
}

function emitListingUpdated(listingId, publicListing) {
  io?.to(`listing:${listingId}`).emit('listing:updated', publicListing);
}

function emitListingLocation(listingId, location) {
  io?.to(`listing:${listingId}`).emit('listing:location', location);
}

module.exports = { initRealtime, emitListingUpdated, emitListingLocation };
