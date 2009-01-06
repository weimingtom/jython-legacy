/* Copyright (c) 2007 Jython Developers */
package org.python.core.io;

import java.io.IOException;
import java.nio.ByteBuffer;
import java.nio.channels.Channel;
import java.nio.channels.ServerSocketChannel;

import com.kenai.constantine.platform.Errno;
import org.python.core.Py;

/**
 * Raw I/O implementation for server sockets.
 *
 * @author Philip Jenvey
 */
public class ServerSocketIO extends SocketIOBase {

    /** The underlying socket */
    private ServerSocketChannel socketChannel;

    /**
     * Construct a ServerSocketIO for the given ServerSocketChannel.
     *
     * @param socketChannel a ServerSocketChannel to wrap
     * @param mode a raw io socket mode String
     */
    public ServerSocketIO(ServerSocketChannel socketChannel, String mode) {
        super(mode);
        this.socketChannel = socketChannel;
    }

    /** {@inheritDoc} */
    public int readinto(ByteBuffer buf) {
        checkClosed();
        checkReadable();
        throw Py.IOError(Errno.ENOTCONN);
    }

    /** {@inheritDoc} */
    public int write(ByteBuffer buf) {
        checkClosed();
        checkWritable();
        throw Py.IOError(Errno.EBADF);
    }

    /** {@inheritDoc} */
    public void close() {
        if (closed()) {
            return;
        }
        try {
            socketChannel.close();
        } catch (IOException ioe) {
            throw Py.IOError(ioe);
        }
        super.close();
    }

    /** {@inheritDoc} */
    public Channel getChannel() {
        return socketChannel;
    }
}
