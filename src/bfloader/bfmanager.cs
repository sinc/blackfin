using System;
using System.Collections.Generic;
using System.Linq;
using FTD2XX_NET;

namespace bfloader
{
    delegate void progressDelegate(int percent);

    class bfmanager
    {
        public const int kWriteBlockSize = 128;
        public const string kDevice_Descriptor = "A7004rbB";
        public const uint kBaudRate = 19200u;
        public const uint kBFBaudRate = 19200u;

        private FTDI m_device;

        public enum loaderCommands: byte {
            LC_ERASE			= 0x10,
            LC_LOAD				= 0x11,
	        LC_RESET_CHIP		= 0x12,
	        LC_BLANK_CHECKING	= 0x13,
	        LC_READ				= 0x14
        }

        public bfmanager(FTDI device)
        {
            m_device = device;
        }

        public void connect()
        {
            FTDI.FT_STATUS fs;
            if (m_device != null)
            {
                if ((fs = m_device.OpenBySerialNumber(kDevice_Descriptor)) != FTDI.FT_STATUS.FT_OK)
                    throw new Exception(string.Format("Невозможно открыть устройство. Устройство не готово. ({0})", fs));
                if ((fs = m_device.SetBaudRate(kBaudRate)) != FTDI.FT_STATUS.FT_OK)
                    throw new Exception(string.Format("Устройство не поддерживает заданную скорость ({0})", fs));
                //uint bytes = 0;
                //m_device.Write(new byte[] { 0xFF }, 1, ref bytes);
                //waitBytes(2);
                //byte[] buf = new byte[2];
                //m_device.Read(buf, 2, ref bytes);
                //if (buf[0] != 0xFE || buf[1] != 0xFF)
                //    throw new Exception("Устройство не готово. Проверьте питание.");
            }
        }

        public void disconnect()
        {
            if (m_device.IsOpen)
                m_device.Close();
        }

        private bool waitBytes(int count)
        {
            uint enableBytes = 0;
            System.Diagnostics.Stopwatch watcher = new System.Diagnostics.Stopwatch();
            watcher.Start();
            while (enableBytes < count)
            {
                if (watcher.ElapsedMilliseconds < 60000)
                    m_device.GetRxBytesAvailable(ref enableBytes);
                else
                    return false;
            }
            return true;
        }

        private byte writeCommand(params byte[] cmd)
        {
            m_device.SetBaudRate(kBaudRate);
            return writeData(cmd);
        }

        private byte writeData(byte[] data)
        {
            m_device.SetBaudRate(kBaudRate);
            if (data.Length > 0)
            {
                uint bytesWritten = 0;
                if (m_device.Write(data, data.Length, ref bytesWritten) == FTDI.FT_STATUS.FT_OK)
                {
                    if (waitBytes(1))
                    {
                        byte[] buf = new byte[1];
                        if (m_device.Read(buf, 1, ref bytesWritten) == FTDI.FT_STATUS.FT_OK)
                        {
                            return buf[0];
                        }
                    }
                }
            }
            return 0xFF;
        }

        public bool load(byte[] data, progressDelegate progress)
        {
            int size = data.Length;
            int steps = size / kWriteBlockSize + 1;
            int step = 0;
            int addr = 0;
            while (size > 0)
            {
                int blockSize = (size > kWriteBlockSize) ? kWriteBlockSize : size;
                if (writeCommand((byte)loaderCommands.LC_LOAD, (byte)blockSize, (byte)addr, (byte)(addr >> 8)) == 0x55)
                {
                    byte[] tmpBuf = new byte[blockSize];
                    for (int i = 0; i < blockSize; i++)
                        tmpBuf[i] = data[addr + i];
                    if (writeData(tmpBuf) != 0x55)
                        return false;
                    else
                    {
                        if (progress != null)
                            progress((step++) * 100 / steps);
                    }
                }
                else
                {
                    return false;
                }
                size -= blockSize;
                addr += blockSize;
            }
            return true;
        }

        public byte[] read()
        {
            byte[] buf = new byte[1];
            byte[] tmp = new byte[65536];
            uint bytes = 0;
            for (uint i = 0; i < 65536; ++i)
            {
                if (writeCommand((byte)loaderCommands.LC_READ, (byte)i, (byte)(i >> 8)) == 0x55 && waitBytes(1))
                {
                    m_device.Read(buf, 1, ref bytes);
                    tmp[i] = buf[0];
                }
            } 
            return tmp;
        }

        public bool checkMemory(byte[] data, progressDelegate progress)
        {
            for (int i = 0; i < data.Length; i++)
            {
                if (writeCommand((byte)loaderCommands.LC_READ, (byte)i, (byte)(i >> 8)) == 0x55 && waitBytes(1))
                {
                    byte[] buf = new byte[1];
                    uint bytes = 0;
                    if (m_device.Read(buf, 1, ref bytes) == FTDI.FT_STATUS.FT_OK && bytes > 0)
                    {
                        if (buf[0] != data[i])
                        {
                            return false;
                        }
                        else
                        {
                            if (progress != null)
                                progress(i * 100 / data.Length);
                        }
                    }
                    else
                    {
                        return false;
                    }
                }
                else
                {
                    return false;
                }
            }
            return true;
        }

        public bool erase()
        {
            return writeCommand((byte)loaderCommands.LC_ERASE) == 0x55;
        }

        public bool blankChecking()
        {
            return writeCommand((byte)loaderCommands.LC_BLANK_CHECKING) == 0x55;
        }

        public bool reset()
        {
            //return writeCommand((byte)loaderCommands.LC_RESET_CHIP) == 0x55;
            uint bytes = 0;
            m_device.Write(new byte[] { (byte)loaderCommands.LC_RESET_CHIP }, 1, ref bytes);
            return true;
        }

        public bool bulkRead(int length, out byte[] buf)
        {
            FTDI.FT_STATUS fs;
            uint bytesReaded = 0;
            buf = new byte[length];
            waitBytes(length);
            m_device.Read(buf, (uint)length, ref bytesReaded);
            return length == bytesReaded;
        }
    }
}
