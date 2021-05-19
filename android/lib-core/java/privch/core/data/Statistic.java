package privch.core.data;

import androidx.room.Entity;
import androidx.room.PrimaryKey;

import java.util.Date;

/**
 * The deserializer requires a default constructor (no parameters)
 */
@Entity
public class Statistic {
    @PrimaryKey(autoGenerate = true)
    public long id;
    public int serverId;

    public Date date;

    public long txBytes;
    public long rxBytes;
}
